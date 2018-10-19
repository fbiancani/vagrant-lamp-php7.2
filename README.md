# vagrant-lamp-php7.2

A simple Vagrant LAMP setup running PHP7.2

## How to use

- Clone this repository into your project
- Run ``vagrant up``
- Add the following lines to your hosts file: 

````
55.55.55.5 app.lan
55.55.55.5 phpmyadmin.lan

````
- Navigate to ``http://app.lan/``
- Navigate to ``http://phpmyadmin.lan/`` (both username and password are 'root')
