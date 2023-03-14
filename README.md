# WebDock
A Dockerised environment for web dev.

Simplified environment for getting up and ready with website development. 
begin developing simply with `docker-compose up -d` and you then can visit 
*localhost* or *127.0.0.1* and you should see the default web page that has been
set within ./websites

You can run the following to begin getting setup with new projects: 
```
./factory.sh create website
```

which will generate a file in the following: 
- ./server/sites-available/website.conf
- ./websites/website

as well as generate a line within your /etc/hosts file upon running this and
you should then be ablre to just navigate on over to the new website created 
at website.test 