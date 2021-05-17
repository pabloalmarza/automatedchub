curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
sudo mkdir /home/synopsysctl
cd /home/synopsysctl
sudo wget https://github.com/blackducksoftware/synopsysctl/releases/download/v2.1.0/synopsysctl-linux-amd64-2.1.0.tar.gz
sudo tar -xvf *.tar.gz
sudo mkdir /home/yaml
sudo chown -R ubuntu:ubuntu /home/yaml
sudo mkdir /home/certs
cd /home/certs
sudo openssl req -newkey rsa:2048 -nodes -keyout key.pem -x509 -days 365 -out certificate.pem -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=example.com"
sudo chown ubuntu:ubuntu -R /home/certs
kubectl create ns hub
kubectl create secret generic hub-blackduck-webserver-certificate -n hub --from-file=WEBSERVER_CUSTOM_CERT_FILE=/home/certs/certificate.pem --from-file=WEBSERVER_CUSTOM_KEY_FILE=/home/certs/key.pem
git clone https://github.com/blackducksoftware/hub.git /home/hub
cd /home/hub/
helm install hub . --namespace hub --set enablePersistentStorage=true --set postgres.isExternal=false --set sealKey=blackduckblackduckblackduckblack --set exposeui=true -set exposedServiceType=LoadBalancer --set enableSourceCodeUpload=true --set enableBinaryScanner=true --set tlsCertSecretName=hub-blackduck-webserver-certificate --set postgres.adminPassword=blackduck --set postgres.userUserName=blackduck_user --set postgres.userPassword=blackduck -f small.yaml
