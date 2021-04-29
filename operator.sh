#!/bin/bash
for arg in "$@"
do
    case $arg in
        -i=*|--install=*)
        HUB_VERSION="${arg#*=}"
        CREATE=1
        shift # Remove --initialize from processing
        ;;
        -h|--help)
        echo "-i --install          removes current install and repaces it with specific empty version (specify version)"
        echo "-d --delete-volumes   deletes old volumes when creating a new stack"
        echo "-a --alert-version    installs alert version"
        echo "-u --upgrade-version  upgrade server to specific version (must be newer)"
        echo "-n --names            stack name (only to create)"
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
password="Puavep*13033**"
get_stack_name(){
 OLD_INSTANCE_NAME=$(ssh -t pablon@eng-hub-pnavarrete.dc1.lan 'echo '$password' | sudo -S docker stack ls --format "{{.Name}}"' | sed 's/.*: //')
}
delete_stack(){
  echo "actually deleting $OLD_INSTANCE_NAME"
  ssh -t pablon@eng-hub-pnavarrete.dc1.lan 'echo '$password' | sudo -S docker stack rm $(sudo -S docker stack ls --format "{{.Name}}")'
}
check_containers(){
  containers=$(ssh -t pablon@eng-hub-pnavarrete.dc1.lan 'echo '$password' | sudo -S docker ps -f name='$OLD_INSTANCE_NAME' -q' | sed 's/.*: //' | wc -l)
  while [ $containers -ge 2 ]
    do
      sleep 5
      containers=$(ssh -t pablon@eng-hub-pnavarrete.dc1.lan 'echo '$password' | sudo -S docker ps -f name='$OLD_INSTANCE_NAME' -q' | sed 's/.*: //' | wc -l)
      echo "iteration $containers"
done

}
delete_volumes(){
  ssh -t pablon@eng-hub-pnavarrete.dc1.lan 'echo '$password' | sudo -S docker volume rm $(sudo -S docker volume ls -q)'
}
download_hub(){
  ssh -t pablon@eng-hub-pnavarrete.dc1.lan 'echo '$password' | sudo -S rm -Rf /home/remote_hub'
  ssh -t pablon@eng-hub-pnavarrete.dc1.lan 'echo '$password' | sudo -S git clone https://github.com/blackducksoftware/hub.git -b release/'$1' /home/remote_hub'
}
deploy_stack(){
    ssh -t pablon@eng-hub-pnavarrete.dc1.lan 'echo '$password' | sudo -S docker stack deploy -c /home/remote_hub/docker-swarm/docker-compose.yml '$INSTANCE_NAME''
}

if [ "$CREATE" == "1" ] && [ "$UPGRADE" == "1" ]
then
  echo "Only one option can be selected"
fi

if [ "$CREATE" != "1" ] && [ "$UPGRADE" != "1" ]
then
  echo "One option must be selected (create or upgrade)"
fi

if [ "$CREATE" == "1" ] && [ "$UPGRADE" != "1" ]
then
  get_stack_name
  echo "will remove stack" $INSTANCE_NAME
  delete_stack
  check_containers $INSTANCE_NAME
  if [ "$DELETE" == "1" ]
  then
    delete_volumes
  fi
  download_hub $HUB_VERSION
  if [ -z "$INSTANCE_NAME" ]
    then
      INSTANCE_NAME="hub"
    fi
  deploy_stack $INSTANCE_NAME

fi

if [ "$CREATE" != "1" ] && [ "$UPGRADE" == "1" ]
then
  echo "upgrade to $UPGRADE_HUB_VERSION"
  get_stack_name

fi

#if [ -z "${DEPLOY_ENV}" ]
#then
# Read Password
#echo -n Password:
#read -s password2
#password="Puavep*13033**"
#echo
# Run Command
#ssh -t pablon@eng-hub-pnavarrete.dc1.lan 'echo '$password' | sudo -S docker stack ls -q'
#fi

#download_alert(){

#}
#start_stack(){

#}
