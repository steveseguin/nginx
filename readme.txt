sudo apt-get update
sudo apt-get install git -y
cd ~
git clone https://github.com/steveseguin/nginx.git
cd nginx
sudo chmod +x deploy.sh
./deploy.sh