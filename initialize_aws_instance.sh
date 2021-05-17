  for arg in "$@"
do
    case $arg in
        -v=*|--version=*)
        HUB_VERSION="${arg#*=}"
        shift # Remove --cache= from processing
        ;;
        -a=*|--alert=*)
        ALERT_VERSION="${arg#*=}"
        ;;
    esac
done
  
  sudo mkfs -t xfs /dev/nvme1n1
  sudo mkdir /data
  sudo mount /dev/nvme1n1 /data
  sudo yum install -y yum-utils
  sudo amazon-linux-extras install docker -y
  sudo systemctl start docker
  sudo sed -i 's/dockerd/dockerd\ -g\ \/data\/docker/g' /lib/systemd/system/docker.service
  sudo systemctl stop docker
  sudo systemctl daemon-reload
  sudo systemctl start docker
  sudo yum -y install git
  sudo git clone https://github.com/blackducksoftware/hub.git /home/hub -b $HUB_VERSION
  sudo git clone https://github.com/blackducksoftware/blackduck-alert.git -b $ALERT_VERSION /home/alert
  sudo sed -i  s/SE_ALERT=0/USE_ALERT=1/ /home/hub/docker-swarm/hub-webserver.env
  sudo sed -i  s/ALERT_ENCRYPTION_GLOBAL_SALT=/ALERT_ENCRYPTION_GLOBAL_SALT=blackduckblackduckblackduckblack/ /home/alert/deployment/blackduck-alert.env
  sudo sed -i  s/ALERT_ENCRYPTION_PASSWORD=/ALERT_ENCRYPTION_PASSWORD=blackduckblackduckblackduckblack/ /home/alert/deployment/blackduck-alert.env
  sudo sed -i  s/ALERT_VERSION_TOKEN/$ALERT_VERSION/ /home/alert/deployment/docker-swarm/hub/docker-compose.yml
  sudo cp /home/alert/deployment/blackduck-alert.env /home/hub/docker-swarm
  sudo cp /home/alert/deployment/docker-swarm/docker-compose.local-overrides.yml /home/hub/docker-swarm/docker-compose.local-overrides.alert.yml
  sudo cp /home/alert/deployment/docker-swarm/hub/docker-compose.yml /home/hub/docker-swarm/docker-compose.alert.yml
  sudo docker swarm init
  sudo docker stack deploy -c /home/hub/docker-swarm/docker-compose.yml -c /home/hub/docker-swarm/docker-compose.alert.yml -c /home/hub/docker-swarm/docker-compose.local-overrides.alert.yml hub
