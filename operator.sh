for arg in "$@"
do
    case $arg in
        -i=*|--install=*)
        HUB_VERSION="${arg#*=}"
        CREATE=1
        shift # Remove --initialize from processing
        ;;      
        -n=*|--name=*)
        INSTANCE_NAME="${arg#*=}"
        shift # Remove --cache= from processing
        ;;
        -a=*|--alert-version=*)
        ALERT_VERSION="${arg#*=}"
        CREATE_ALERT=1
        shift # Remove --cache= from processing
        ;;
        -u=*|--upgrade-version=*)
        UPGRADE_HUB_VERSION="${arg#*=}"
        UPGRADE=1
        shift # Remove --cache= from processing
        ;;
        -d|--delete-volumes)
        DELETE=1
        shift # Remove argument name from processing
        ;;
    esac
done

delete_stack(){
  StackId=$(docker stack ls --format "{{.Name}}")
  docker stack rm $StackId
}

check_containers(){
  docker ps -f name=$StackId -q
  containers=$(docker ps -f name=$StackId -q | sed 's/.*: //' | wc -l)
  while [ $containers -ge 2 ]
    do
      sleep 5
      docker ps -f name=$StackId -q
      containers=$(docker ps -f name=$StackId -q | sed 's/.*: //' | wc -l)
done
}

delete_volumes(){
  docker volume rm $(docker volume ls -q)
}

download_hub(){
  rm -Rf /home/remote_hub
  git clone https://github.com/blackducksoftware/hub.git -b release/$1 /home/remote_hub
}

deploy_stack(){
    docker stack deploy -c /home/remote_hub/docker-swarm/docker-compose.yml $INSTANCE_NAME
}

if [ "$CREATE" == "1" ] && [ "$UPGRADE" == "1" ]
then
  exit
fi

if [ "$CREATE" != "1" ] && [ "$UPGRADE" != "1" ]
then
  exit
fi

if [ "$CREATE" == "1" ] && [ "$UPGRADE" != "1" ]
then
  delete_stack
  check_containers
  delete_volumes
  download_hub $HUB_VERSION
  deploy_stack
fi
