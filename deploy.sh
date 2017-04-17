## Update and prep basics
sudo apt-get update
sudo apt-get install make
sudo apt-get install git -y
sudo apt-get install build-essential -y

## download nginx-rtmp and openssl 
mkdir ~/build
cd ~/build
git clone git://github.com/arut/nginx-rtmp-module.git
wget https://www.openssl.org/source/openssl-1.0.2g.tar.gz
tar xzf openssl-1.0.2g.tar.gz
wget https://openresty.org/download/openresty-1.11.2.2.tar.gz
wget https://openresty.org/download/openresty-1.11.2.2.tar.gz.asc
gpg --keyserver pgpkeys.mit.edu --recv-key A0E98066
gpg openresty-1.11.2.2.tar.gz.asc
## Ensure it says "Good signature" somewhere in the output

tar -xvf openresty-1.11.2.2.tar.gz
cd openresty-1.11.2.2
sudo apt-get install libreadline-dev libncurses5-dev libpcre3-dev libssl-dev perl curl -y
./configure -j2 --with-pcre-jit --with-ipv6  --add-module=/home/ubuntu/build/nginx-rtmp-module --with-http_ssl_module --without-http_rewrite_module --with-openssl=/home/ubuntu/build/openssl-1.0.2g  --without-http_gzip_module
make -j2
sudo make install
export PATH=/usr/local/openresty/bin:/usr/local/openresty/nginx/sbin:$PATH

## Move the service deploy script to the init.d directory & make executable
cd ~
git clone https://github.com/steveseguin/nginx.git
sudo mv ~/nginx/nginx-init.sh /etc/init.d/nginx
sudo chmod +x /etc/init.d/nginx

## Add nginx to the system startup
sudo /usr/sbin/update-rc.d -f nginx defaults
sudo service nginx start

######################
## sudo service nginx stop 
## sudo service nginx start 
## sudo service nginx restart
## sudo service nginx reload
################################

## Let's configure it for RTMP ingest using Steve Seguin's example configuration.
cd /usr/local/openresty/nginx/conf
sudo mv nginx.conf nginx.conf.bak
sudo mv ~/nginx/nginx.conf ./nginx.conf

### You can view server stats with the following additional @ http://thisserver.com/stat
sudo mv ~/nginx/nginx.conf ../stat.xsl
sudo service nginx restart

## Time to install SSL (optional)
### Below is how you can install a FREE SSL cert, which lasts 90 days. It requires a domain name.
# cd ~
# wget https://dl.eff.org/certbot-auto
# chmod a+x certbot-auto
# ./certbot-auto ##### You will need to press "Y" and then Enter during the script 
# sudo service nginx stop 
# sudo ./certbot-auto certonly --standalone -d rtmp.stageten.tv ## << substitute current hostname name here
# sudo service nginx start 
#### Update nginx's conf file as needed, then restart. I don't see a point in adding SSL though at this time, but it's there.
#######

### Install FFMPEG ; Optional, but highly recommended if you wish to do advanced features with NGINX
sudo apt-add-repository ppa:mc3man/trusty-media -y
sudo apt-get update
sudo apt-get install ffmpeg -y
## This version of FFMPEG should support Nvidia GPU; x264, x265, OPUS, mp3, aac, etc.
##

ffmpeg -version 
##
echo 'External IP:' $(wget http://ipinfo.io/ip -qO -)
######
#### PERFORMING A 10 SECOND TEST #

timeout --kill-after=10 9 ffmpeg -re -f lavfi -i testsrc="size=640x360:rate=30" -f lavfi -i sine=f=220:b=1 -af volume=0.1 -codec:a aac -strict -2 -codec:v libx264 -preset ultrafast -tune zerolatency -pixel_format yuv420p -g 48 -f flv rtmp://$(wget http://ipinfo.io/ip -qO -)/test/streamname

###############
## And now just configure the NGINX conf file to suit your needs
## cd /usr/local/nginx/conf
## ls -l
## vi nginx.conf