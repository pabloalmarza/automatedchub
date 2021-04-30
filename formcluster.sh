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
cd /home/synopsysctl
./synopsysctl create blackduck native hub -n hub --version 2021.2.0 --expose-ui LOADBALANCER --admin-password blackduck --user-password blackduck --seal-key blackduckblackduckblackduckblack --certificate-file-path /home/certs/certificate.pem --certificate-key-file-path /home/certs/key.pem > /home/yaml/blackduck.yaml
kubectl create ns hub
kubectl create -f /home/yaml/blackduck.yaml
