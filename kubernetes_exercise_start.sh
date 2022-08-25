sudo apt-get -y install helm
sudo apt-get -y install jq
sudo git clone https://github.com/pabloalmarza/kubernetes-hub-exercises.git /home/exercises
chown -R ubuntu:ubuntu /home/exercises
git clone https://github.com/blackducksoftware/hub.git -b v2022.7.0 /home/hub
