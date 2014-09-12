#!/usr/bin/env bash

echo -n "==> What will be the domain of the site? "
read -e domain

if [ $domain = '' ]
then
    
    echo "The domain name can not be empty"
    exit

else

    echo "==> Creating the Server Block"

    block="server {
        listen 80;
        server_name $domain;
        root /var/www/$domain/public;

        index index.html index.htm index.php;

        charset utf-8;

        location / {
            try_files \$uri \$uri/ /index.php?\$query_string;
        }

        location = /favicon.ico { access_log off; log_not_found off; }
        location = /robots.txt  { access_log off; log_not_found off; }

        access_log off;
        error_log  /var/log/nginx/$domain-error.log error;

        error_page 404 /index.php;

        sendfile off;

        location ~ \.php$ {
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass unix:/var/run/php5-fpm.sock;
            fastcgi_index index.php;
            include fastcgi_params;
        }

        location ~ /\.ht {
            deny all;
        }
    }
    "

    echo "$block" > "/etc/nginx/sites-available/$domain"
    ln -fs "/etc/nginx/sites-available/$domain" "/etc/nginx/sites-enabled/$domain"

    echo "==> Restarting Nginx "
    service nginx restart

    echo "==> Restarting PHP5-FPM "
    service php5-fpm restart

fi


echo -n "==> Do you want to create the root directory? [yes|no] "
read -e rootpath

if [ $rootpath = 'yes' ]
then

    echo "==> Creating the root directory in: /var/www/$domain "
    mkdir /var/www/$domain

fi
