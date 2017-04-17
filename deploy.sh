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