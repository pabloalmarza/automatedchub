curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
sudo apt-get -y install jq
#sudo git clone https://github.com/pabloalmarza/kubernetes-hub-exercises.git /home/exercises
sudo git clone https://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@github.com/pabloalmarza/kubernetes-hub-exercises-master.git exercises
sudo chown -R ubuntu:ubuntu /home/exercises
git clone https://github.com/blackducksoftware/hub.git -b v2022.7.0 /home/hub
sudo chown -R ubuntu:ubuntu /home/hub
sudo chmod 400 /home/hub/certs/kube_controller.pem > /dev/null 2>&1
