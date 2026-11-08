## Deploy script for NGINX on Ubuntu 16.04 LTS

- NGINX 2.x.x
- NGINX-RTMP module
- NGINX-LUA module
- FFMPEG
- SSL

sudo apt-get update
sudo apt-get install git -y
cd ~
git clone https://github.com/steveseguin/nginx.git
cd nginx
sudo chmod +x deploy.sh
./deploy.sh

## Development checks

python3 -m unittest discover -s tests -v

These tests check configure arguments in a temporary directory. They do not
download dependencies, install packages, or start services.
