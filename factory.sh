#!/bin/bash

#-----------------------------------------------------------------------------------------------------------------------
# Script Intro...
#-----------------------------------------------------------------------------------------------------------------------

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
#       is how I want the particular end goal to work here, however right now the command would be
#       ./factory create {website name} and then you can just go to {website name}.test in your browser without having
#       to perform anything else yourself.
#
# todo: ./factory destroy:{website name}
#       is how to be able to destroy a particular website that might have been added however no longer wanted...
#       sudo rm ./server/sites-enabled/{website name}.conf && sudo rm -r ./websites/{website name}
#
# This particular method *needs* right now to be ran as sudo (as it touches /etc/hosts).

#-----------------------------------------------------------------------------------------------------------------------
# Script Variables
#-----------------------------------------------------------------------------------------------------------------------

action=$1;
website=$2;

# the host in which when running the script (if creating one) that will be bound to, this *could* potentially be passed
# as a parameter to make it easier for the script so that the user could run:
# ./factory.sh create website -host=192.168.0.1
host=127.0.0.1;

if [ -z "$action" ] || [ -z "$website" ]; then
    echo "action or website hasn't been provided";
    exit;
fi

#-----------------------------------------------------------------------------------------------------------------------
# Create Utilities...
#-----------------------------------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------------------------------------
# Server Template...
#
# boiler plate content for the necessary website that's being created. This would be appended into
# ./server/sites-enabled/*.conf; which will enable the developer to then start accessing the domain without having to
# visit localhost
#-----------------------------------------------------------------------------------------------------------------------

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

#-----------------------------------------------------------------------------------------------------------------------
# Website Template...
#
# Boiler plate for your website, this is just a basic html snippet appended into the index.php file which would then
# allow the developer to begin working on the website with ease.
#-----------------------------------------------------------------------------------------------------------------------

read -r -d '' web_index <<- EOL
<!DOCTYPE html>
<html lang="EN">
    <head>
        <title>Default WebDock landing page...</title>
        <style>
            html,
            html body {
                padding: 0;
                margin: 0;
                background-color: #181818;
            }

            body {
                height: 100vh;
                width: 100%;
                display: flex;
                align-items: center;
                justify-content: center;
            }

            body > div {
                text-align: center;
            }

            h1 {
                color: #ffffff;
            }

            h1 span {
                color: #ffa500;
            }

            p {
                color: rgba(255,255,255,0.75);
            }
        </style>
    </head>
    <body>
        <div>
            <h1>Welcome to <span>$website</span></h1>
            <p>This is your boiler plate website, feel free to modify it as you see fit.</p>
        </div>
    </body>
</html>
EOL

# Utility method for handling updating the hosts file of the system, which would need to point localhost to the name of
# the website that we've just created. so the developer would then be able to navigate to website.extension on their
# system.
# todo -> this particular method wants to check the contents of the hosts file and see if the entry already exists as
#         there wouldn't be much of a point in adding it again.
handle_create_hosts() {
    echo $host ${website}.test www.${website}.test \# from factory >> /etc/hosts;
    echo "step 1: /etc/hosts has been updated to accommodate $website onto $host";
}

# Utility method for handling the creation of the website's configuration file, which will be created and dropped within
# the sites enabled within the server... at the current moment of development this would strictly be for a php/html based
# implementation devoid of proxies for frontend application development. however that might be something to consider when
# running this application -> appending some boilerplate proxy reverses for a frontend stack instead.
handle_create_configuration() {
    if [ ! -f "./server/sites-enabled/$website.conf" ]; then
        echo -e "$server" >> "./server/sites-enabled/${website}.conf";
        echo "step 2: $website.conf has been created within ./server/sites-enabled/$website.conf";
        return;
    fi
    echo "step 2: $website.conf already existed within ./server/sites-enabled/$website.conf";
}

# Utility method for handling the creation of the website, when hitting this part; within the environment we are going
# to generate the necessary boiler plate for the website; this particular snippet is going to check if that particular
# website already exists, so it doesn't get made twice, or doesn't happen to overwrite or append to what might already
# be there.
# This particular method is also going to want to check whether there has been a symbolic link made for the particular
# website also.
handle_create_website_creation() {
    if [ ! -d "./websites/$website" ]; then
        mkdir "./websites/$website";
    fi
    if [ ! -d "./website/$website/public" ]; then
        mkdir "./websites/$website/public";
    fi
    if [ ! -f "./websites/$website/public/index.php" ]; then
        echo -e "$web_index" >> "./websites/$website/public/index.php";
    fi
    echo "step 3: $website has been generated within ./websites/$website/public/";
}

#-----------------------------------------------------------------------------------------------------------------------
# Remove Utilities...
#-----------------------------------------------------------------------------------------------------------------------

handle_remove_website_config() {
    if [ -f "./server/sites-enabled/$website.conf" ]; then
        rm "./server/sites-enabled/$website.conf";
        echo "$website.conf has been removed from ./server/sites-enabled";
        return;
    fi
    echo "$website.conf does not exist within ./server/sites-enabled";
}

# Check to see whether there is a directory for the website that the user wants to remove.
handle_remove_website_directory() {
    if [ -d "./websites/$website" ]; then
        rm -r "./websites/$website";
        echo "$website has been removed from ./websites";
        return;
    fi
    echo "$website does not exist within ./websites";
}

#-----------------------------------------------------------------------------------------------------------------------
# Run The Script...
#-----------------------------------------------------------------------------------------------------------------------

# if the user has said that the action is to create then we're going to want to run the necessary scripts to create the
# particular website.
if [ "$action" == "create" ]; then
    handle_create_hosts;
    handle_create_configuration;
    handle_create_website_creation;
fi

# if passing the action as remove then the script is going to start running the necessary methods in order to tear down
# the particular website that the developer will have passed.
if [ "$action" == "remove" ]; then
    handle_remove_website_config
    handle_remove_website_directory;
fi

# After all the above had been ran and the new website is ready to be worked on, we can then restart the nginx process
# so that the new website can be immediately accessed without having to perform any rebuild.
docker-compose exec server nginx -s reload