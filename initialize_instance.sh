  for arg in "$@"
do
    case $arg in
        -v=*|--version=*)
        HUB_VERSION="release/${arg#*=}"
        shift # Remove --cache= from processing
        ;;
        -a=*|--alert=*)
        ALERT_VERSION="release/${arg#*=}"
        ;;
    esac
done
  
  sudo mkfs -t xfs /dev/nvme1n1
  sudo mkdir /data
  sudo mount /dev/nvme1n1 /data
  sudo yum install -y yum-utils
  sudo amazon-linux-extras install docker
  sudo systemctl start docker
  sudo sed -i  s/dockerd/dockerd\ -g\ /data/docker/ /lib/systemd/system/docker.service
  sudo systemctl stop docker
  sudo systemctl daemon-reload
  sudo systemctl start docker
  sudo yum -y install git
  sleep 15
  sudo git clone https://github.com/blackducksoftware/hub.git /home/hub -b release/$HUB_VERSION
  sudo git clone https://github.com/blackducksoftware/blackduck-alert.git -b $ALERT_VERSION /home/alert
  sudo sed -i  s/SE_ALERT=0/USE_ALERT=1/ /home/hub/docker-swarm/hub-webserver.env
  sudo sed -i  s/ALERT_ENCRYPTION_GLOBAL_SALT=/ALERT_ENCRYPTION_GLOBAL_SALT=blackduckblackduckblackduckblack/ /home/alert/deployment/blackduck-alert.env
  sudo sed -i  s/ALERT_ENCRYPTION_PASSWORD=/ALERT_ENCRYPTION_PASSWORD=blackduckblackduckblackduckblack/ /home/alert/deployment/blackduck-alert.env
  sudo sed -i  s/ALERT_VERSION_TOKEN/$ALERT_VERSION/ /home/alert/deployment/docker-swarm/hub/docker-compose.yml
  sudo cp /home/alert/deployment/blackduck-alert.env /home/hub/docker-swarm
  sudo cp /home/alert/deployment/docker-swarm/docker-compose.local-overrides.yml /home/hub/docker-swarm/docker-compose.local-overrides.alert.yml
  sudo cp /home/alert/deployment/docker-swarm/hub/docker-compose.yml /home/hub/docker-swarm/docker-compose.alert.yml
  docker swarm init
  sudo docker stack deploy -c /home/hub/docker-swarm/docker-compose.yml -c /home/hub/docker-swarm/docker-compose.alert.yml -c /home/hub/docker-swarm/docker-compose.local-overrides.alert.yml hub
