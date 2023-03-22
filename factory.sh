#!/bin/bash

#-----------------------------------------------------------------------------------------------------------------------
# Script Intro...
#-----------------------------------------------------------------------------------------------------------------------

# Intro to this particular script
# This script is designed to make it easier for just setting up the necessary boilerplate stuff that each and every
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
user=$3;
with=$4


# the host in which when running the script (if creating one) that will be bound to, this *could* potentially be passed
# as a parameter to make it easier for the script so that the user could run:
# ./factory.sh create website -host=192.168.0.1
host=127.0.0.1;

if [ -z "$action" ] || [ -z "$website" ]; then
    echo "action or website hasn't been provided";
    exit;
fi

if [ "$action" != "create" ] && [ "$action" != "remove" ]; then
    echo "first passed parameter (action) wants to be [create|remove]";
    exit;
fi

#-----------------------------------------------------------------------------------------------------------------------
# Server Template...
#
# boilerplate content for the necessary website that's being created. This would be appended into
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
# Boilerplate for your website, this is just a basic html snippet appended into the index.php file which would then
# allow the developer to begin working on the website with ease.
#-----------------------------------------------------------------------------------------------------------------------

read -r -d '' web_index <<- EOL
<!DOCTYPE html>
<html lang="EN">
    <head>
        <title>$website</title>
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
                font-family: ProximaNova,
                             -apple-system,
                             BlinkMacSystemFont,
                             "Segoe UI",
                             Roboto,
                             "Helvetica Neue",
                             Arial,
                             sans-serif
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
            <p>This is your boilerplate website, feel free to modify it as you see fit.</p>
        </div>
    </body>
</html>
EOL

#-----------------------------------------------------------------------------------------------------------------------
# Composer Template...
#
# Boilerplate for the composer.json file that will be included with the project if the script has specified that this
# is going to be wanted. if it is then this will be transferred across and composer install will be initiated from the
# docker-compose exec php container.
#-----------------------------------------------------------------------------------------------------------------------

read -r -d '' composer <<- EOL
{
    "name": "$website/$website",
    "description": "$website made by the factory... fil in your at your own discretion",
    "type": "project",
    "license": "mit",
    "autoload": {
        "psr-4": {
            "${website^^}\\\\\\\\": "src/"
        }
    },
    "authors": [
        {
            "name": "First Last",
            "email": "first.last@provider.com"
        }
    ],
    "require": {}
}
EOL

#-----------------------------------------------------------------------------------------------------------------------
# Create Utilities...
#-----------------------------------------------------------------------------------------------------------------------

# Utility method for handling updating the hosts file of the system, which would need to point localhost to the name of
# the website that we've just created. so the developer would then be able to navigate to website.extension on their
# system.
handle_create_hosts() {
    while IFS= read -r line; do
        if [[ "$line" == *"$website"* ]]; then
            echo "step 1: /etc/hosts already includes entry for $website moving on...";
            return;
        fi
    done <<< $(cat "/etc/hosts");
    echo "$host ${website}.test www.${website}.test # -> from factory" >> /etc/hosts;
    echo "step 1: /etc/hosts has been updated to accommodate $website onto $host";
}

# Utility method for handling the creation of the website's configuration file, which will be created and dropped
# within the sites enabled within the server... at the current moment of development this would strictly be for a
# php/html based implementation devoid of proxies for frontend application development. however that might be something
# to consider when running this application -> appending some boilerplate proxy reverses for a frontend stack instead.
handle_create_configuration() {
    if [ ! -f "./server/sites-enabled/$website.conf" ]; then
        echo -e "$server" >> "./server/sites-enabled/${website}.conf";
        echo "step 2: $website.conf has been created within ./server/sites-enabled/$website.conf";
        return;
    fi
    echo "step 2: $website.conf already existed within ./server/sites-enabled/$website.conf";
}

# Utility method for handling the creation of the website, when hitting this part; within the environment we are going
# to generate the necessary boilerplate for the website; this particular snippet is going to check if that particular
# website already exists, so it doesn't get made twice, or doesn't happen to overwrite or append to what might already
# be there.
# todo - This particular method is also going to want to check whether there has been a symbolic link made for the
#        particular website also.
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

# Utility method for handling the creation of the composer side, if the script had been executed with the composer being
# included, then we're going to need to set up the necessary composer files and auto-loading directories. upon this
# happening, we're then going to want to run the necessary container's directory composer install so that the files
# will be generated and auto-loading will be in place from the minute the user opens the web page.
handle_create_composer() {
    if [[ "$with" == *"--with-composer"* ]]; then
        if [ ! -d "./websites/$website/src" ]; then
            mkdir "./websites/$website/src";
        fi
        echo -e "$composer" >> "./websites/$website/composer.json";
        echo "step 3.1 composer.json has been added to ./websites/$website";
        docker-compose run -w "/var/www/html/$website" php composer install;
        echo "step 3.2 composer has finished installing project";
    fi
}

# Utility for handling the permissions to set the user for the one that the person specifies for within the command...
# if the user passes one that is, if they do not this will bomb out and do nothing. (Given the fact that this command
# may be ran as sudo, the directories and files are going to be created with the user "root" and the permissions for
# files will be non modifiable... thus will need transferring ownership or alerting the user that the ownership is set
# to a particular setting).
handle_permissions() {
    if [ ! -z "$user" ]; then
        chown -R $user:$user "./websites/$website";
        echo "step 4: Ownership of the files have been given to the user: [$user:$user] in [./websites/$website]";
        return;
    fi
    echo "step 4: No user specified, ownership will be given to [root:root] in [./websites/$website]";
}

#-----------------------------------------------------------------------------------------------------------------------
# Remove Utilities...
#-----------------------------------------------------------------------------------------------------------------------

# Utility method for the removal of the particular websites from the hosts file - this particular snippet would require
# the use of sudo. find all examples of the passed parameter "www.website.test" which is absolute to what the website
# would be called within the hosts file, which will limit the potential of having another similarly named website being
# stripped from the hosts file...
handle_remove_hosts() {
    sed -i "/www.$website.test/d" "/etc/hosts";
    echo "$website has been removed from the /etc/hosts; $website will no longer be accessible.";
}

# Utility method for the removal of the configuration files that reside within ./server/sites-enabled and contains the
# website.conf. This would be needed in order for the removal of the particular configuration on the nginx server so
# the page will no longer be available.
handle_remove_website_config() {
    if [ -f "./server/sites-enabled/$website.conf" ]; then
        rm "./server/sites-enabled/$website.conf";
        echo "$website.conf has been removed from ./server/sites-enabled";
        return;
    fi
    echo "$website.conf does not exist within ./server/sites-enabled";
}

# Utility method which will remove the website from the ./websites directory, cleaning up the space that that particular
# website might have taken up.
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
    handle_create_composer;
    handle_permissions;
fi

# if passing the action as remove then the script is going to start running the necessary methods in order to tear down
# the particular website that the developer will have passed.
if [ "$action" == "remove" ]; then
    handle_remove_hosts;
    handle_remove_website_config
    handle_remove_website_directory;
fi

# After all the above had been ran and the new website is ready to be worked on, we can then restart the nginx process
# so that the new website can be immediately accessed without having to perform any rebuild.
docker-compose exec server nginx -s reload