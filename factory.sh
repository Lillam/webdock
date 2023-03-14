#!/bin/bash

# Intro to this particular script
# This script is designed to make it easier for just setting up the necessary boiler plate stuff that each and every
# website is going to need... rather than going to each individual location and adding the necessary configurations it
# can be consolidated into this particular helper; which is going to take care of the following:
# adding the host into the hosts /etc/hosts file
# adding the necessary server configuration file into nginx where the website is going to be run from
# adding the necessary file and folder structure to teh correct appropriate place (for this particular environment)
# so that you can immediately just hop to creating your website easily.
#
# todo: ./factory create:{website name}
# is how I want the particular end goal to work here, however right now the command would be
# ./factory create {website name} and then you can just go to {website name}.test in your browser without having to
# perform anything else yourself.
#
# todo: ./factory destroy:{website name}
# is how to be able to destroy a particular website that might have been added however no longer wanted...
# sudo rm ./server/sites-enabled/{website name}.conf && sudo rm -r ./websites/{website name}
#
# This particular method *needs* right now to be ran as sudo (as it touches /etc/hosts).

action=$1;
website=$2;
host=127.0.0.1;

if [ -z "$action" ] || [ -z "$website" ]; then
    echo "action or website hasn't been provided";
    exit;
fi

# boiler plate content for the necessary website that's being created. This would be appended into
# ./server/sites-enabled/*.conf; which will enable the developer to then start accessing the domain without having to
# visit localhost
read -r -d '' server <<- EOL
server {
    listen 0.0.0.0:80;
    server_name $website.test www.$website.test;
    root /var/www/html/$website/public;
    index index.php index.html;

    location ~ \.php$ {
        try_files \$uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass php:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param PATH_INFO \$fastcgi_path_info;
    }

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
        gzip_static on;
    }
}
EOL

read -r -d '' web_index <<- EOL
\<?php

\echo \"$website made from the factory\";
EOL

handle_print_to_conf () {
    echo $1 >> ./server/sites-enabled/${website}.conf;
    echo The website $website has been generated within ./server/sites-enabled/${website}.conf
}

# Utility method for handling updating the hosts file of the system, which would need to point localhost to the name of
# the website that we've just created. so the developer would then be able to navigate to website.extension on their
# system.
create_handle_hosts() {
    echo $host ${website}.test www.${website}.test \# from factory >> /etc/hosts;

    echo "Step 1: /etc/hosts has been updated to accommodate $website onto $host";
}

# Utility method for handling the creation of the website's configuration file, which will be created and dropped within
# the sites enabled within the server... at the current moment of development this would strictly be for a php/html based
# implementation devoid of proxies for frontend application development. however that might be something to consider when
# running this application -> appending some boilerplate proxy reverses for a frontend stack instead.
create_handle_configuration() {
    if [ ! -f "./server/sites-enabled/$website.conf" ]; then
        echo -e "$server" >> ./server/sites-enabled/${website}.conf
    fi

    echo "step 2: $website.conf has been created within ./server/sites-enabled/$website.conf";
}

# Utility method for handling the creation of the website, when hitting this part; within the environment we are going
# to generate the necessary boiler plate for the website; this particular snippet is going to check if that particular
# website already exists, so it doesn't get made twice, or doesn't happen to overwrite or append to what might already
# be there.
# This particular method is also going to want to check whether there has been a symbolic link made for the particular
# website also.
create_handle_website_creation() {
    if [ ! -d "./websites/$website" ]; then
        mkdir "./websites/$website";
    fi
    if [ ! -d "./website/$website/public" ]; then
        mkdir "./websites/$website/public";
    fi
    if [ ! -f "./websites/$website/public/index.php" ]; then
        touch "./websites/$website/public/index.php";
    fi

    echo "step 3: $website has been generated within ./websites/$website/public/";
}

if [ "$action" == "create" ]; then
    create_handle_hosts;
    create_handle_configuration;
    create_handle_website_creation;
fi

if [ "$action" == "remove" ]; then

fi

# After all the above had been ran and the new website is ready to be worked on, we can then restart the nginx process
# so that the new website can be immediately accessed without having to perform any rebuild.
docker-compose exec server nginx -s reload