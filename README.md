# WebDock

### A Dockerised environment for web dev

This is a simplified environment dedicated for getting up and ready with
website development with ease. Take away the strain of setting up the server
variables and such with the utilisation of the helper script (__factory.sh__)

To get setup simply clone and run `docker-compose up -d`

---

To set up a new project you can run the following: (*might need sudo*)
```
./factory.sh create {website}
```
which will generate the following:
- ./server/sites-available/{website}.conf
- ./websites/{website}/public/index.php

as well as generate a line within your /etc/hosts file upon running this you
should then be able to just navigate on over to the new website created at
{website}.test

---

If you decide that you no longer desire that project, or you made a mistake 
or just simply want to remove it you can run the following: (*might need sudo*)
```
./factory.sh remove {website}
```

which will remove the following:
- ./server/sites-enabled/{website}.conf
- ./websites/{website}/public/index.php

as well as removing a line within your /etc/hosts file upon running this you
should no longer be able to access {website}.test 