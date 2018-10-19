#!/usr/bin/env bash

Update () {
    echo "-- Update packages --"
    sudo apt-get update
    sudo apt-get upgrade
}
Update

echo "-- Prepare configuration for MySQL --"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password root"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password root"

echo "-- Install tools and helpers --"
sudo apt-get install -y --force-yes python-software-properties vim htop curl git npm

echo "-- Install PPA's --"
sudo add-apt-repository ppa:ondrej/php
sudo add-apt-repository ppa:chris-lea/redis-server

curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

Update

echo "-- Install NodeJS --"
wget -qO- https://deb.nodesource.com/setup_8.x | sudo -E bash -

echo "-- Install Yarn --"

sudo apt-get install cmdtest
sudo apt-get update && sudo apt-get install yarn

echo "-- Install packages --"
sudo apt-get install -y --force-yes apache2 mysql-server git-core nodejs rabbitmq-server redis-server
sudo apt-get install -y --force-yes php7.2-common php7.2-dev php7.2-xml php7.2-json php7.2-opcache php7.2-cli libapache2-mod-php7.2 php7.2 php7.2-mysql php7.2-fpm php7.2-curl php7.2-gd php7.2-mbstring php7.2-bcmath php7.2-zip
Update

echo "-- Configure PHP &Apache --"
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.2/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.2/apache2/php.ini
sudo a2enmod rewrite

echo "-- Creating virtual hosts --"
sudo cp -r www/* /vagrant
sudo rm -rf /var/www
sudo ln -fs /vagrant  /var/www
cat << EOF | sudo tee -a /etc/apache2/sites-available/default.conf
<Directory "/var/www/">
    AllowOverride All
</Directory>

<VirtualHost *:80>
    DocumentRoot /var/www/html
    ServerName app.lan
</VirtualHost>

<VirtualHost *:80>
    DocumentRoot /var/www/phpmyadmin
    ServerName phpmyadmin.lan
</VirtualHost>
EOF
sudo a2ensite default.conf

echo "-- Restart Apache --"
sudo /etc/init.d/apache2 restart

echo "-- Install Composer --"
curl -s https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer

echo "-- Install phpMyAdmin --"
wget -k https://files.phpmyadmin.net/phpMyAdmin/4.8.3/phpMyAdmin-4.8.3-english.tar.gz
sudo tar -xzvf phpMyAdmin-4.8.3-english.tar.gz -C /var/www/
sudo rm phpMyAdmin-4.8.3-english.tar.gz
sudo mv /var/www/phpMyAdmin-4.8.3-english/ /var/www/phpmyadmin

echo "-- Setup databases --"
mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION; FLUSH PRIVILEGES;"
mysql -uroot -proot -e "CREATE DATABASE new_db";

sudo mkdir /var/www/html
cat << EOF | sudo tee -a /var/www/html/index.html
<!doctype html>

<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Hello World!</title>
</head>
<body>
  <h1>Hello World!</h1>
</body>
</html>
EOF
cat << EOF | sudo tee -a /var/www/html/info.php
<?php phpinfo(); ?>
EOF


