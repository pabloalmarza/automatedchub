for arg in "$@"
do
    case $arg in
        -v=*|--version=*)
        HUB_VERSION="${arg#*=}"
        CREATE=1
        shift # Remove --initialize from processing
        ;;
        -h|--help)
        echo "-v --version          removes current install and repaces it with specific empty version (specify version)"
        echo "-a --alert-version    installs alert version"
        echo "-n --name             stack name (only to create)"
        shift # Remove --initialize from processing
        ;;
        -n=*|--name=*)
        INSTANCE_NAME="${arg#*=}"
        NAME=1
        shift # Remove --cache= from processing
        ;;
        -a=*|--alert-version=*)
        ALERT_VERSION="${arg#*=}"
        CREATE_ALERT=1
        shift # Remove --cache= from processing
        ;;
    esac
done

delete_current_stack() {
  # deletes current stack
  stack=$(docker stack ls --format "{{.Name}}")
  docker stack rm $stack
  while [[ $(docker ps --format "{{.Names}}" | grep $stack | wc -l) -ge 1 ]]
  do
  echo  "Waiting for current services to be deleted. Number of active services in stack $stack = $(docker ps --format "{{.Names}}" | grep $stack | wc -l)"
  sleep 3
  done
  sleep 10
}

delete_volumes() {
  # deletes current volumes
  docker volume rm $(docker volume ls -q)
}

clean_hub_folder(){
  rm -Rf /home/hub_automation

}

clean_alert_folder(){
  rm -Rf /home/alert_automation
}

download_blackduck_charts(){
  git clone https://github.com/blackducksoftware/hub.git -b release/$HUB_VERSION /home/hub_automation
}

download_alert_charts(){
  git clone https://github.com/blackducksoftware/blackduck-alert.git -b $ALERT_VERSION /home/alert_automation
}

configure_alert_files(){
  sed -i  s/USE_ALERT=0/USE_ALERT=1/ /home/hub_automation/docker-swarm/hub-webserver.env
  sed -i  s/ALERT_ENCRYPTION_GLOBAL_SALT=/ALERT_ENCRYPTION_GLOBAL_SALT=blackduckblackduckblackduckblack/ /home/alert_automation/deployment/blackduck-alert.env
  sed -i  s/ALERT_ENCRYPTION_PASSWORD=/ALERT_ENCRYPTION_PASSWORD=blackduckblackduckblackduckblack/ /home/alert_automation/deployment/blackduck-alert.env
  sed -i  s/ALERT_VERSION_TOKEN/$ALERT_VERSION/ /home/alert_automation/deployment/docker-swarm/hub/docker-compose.yml
  cp /home/alert_automation/deployment/blackduck-alert.env /home/hub_automation/docker-swarm
  cp /home/alert_automation/deployment/docker-swarm/docker-compose.local-overrides.yml /home/hub_automation/docker-swarm/docker-compose.local-overrides.alert.yml
  cp /home/alert_automation/deployment/docker-swarm/hub/docker-compose.yml /home/hub_automation/docker-swarm/docker-compose.alert.yml

}

start_stack(){
  docker stack deploy -c /home/hub_automation/docker-swarm/docker-compose.yml $INSTANCE_NAME
}

start_stack_alert(){
  docker stack deploy -c /home/hub_automation/docker-swarm/docker-compose.yml -c /home/hub_automation/docker-swarm/docker-compose.alert.yml -c /home/hub_automation/docker-swarm/docker-compose.local-overrides.alert.yml $INSTANCE_NAME
}

if [ "$NAME" != "1" ]
then
  INSTANCE_NAME="hub"
fi
echo "CREATE $CREATE"
echo "CREATE_ALERT $CREATE_ALERT"

if [ "$CREATE" == "1" ] && [ "$CREATE_ALERT" != "1" ]
then
  delete_current_stack
  delete_volumes
  clean_hub_folder
  download_blackduck_charts
  start_stack
fi

if [ "$CREATE" == "1" ] && [ "$CREATE_ALERT" == "1" ]
then
  delete_current_stack
  delete_volumes
  clean_hub_folder
  clean_alert_folder
  download_blackduck_charts
  download_alert_charts
  configure_alert_files
  start_stack_alert
fi
