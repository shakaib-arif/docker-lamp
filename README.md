# Docker-LAMP
It's a single container docker LAMP stack using `runit` as an init scheme for its processes. We are using runit so we can run multiple processes in our container which will be administered by it. If you want to learn more about runit then check out the following [link](https://github.com/shakaib-arif/runsv/) of my runit docker container.

# LAMP Usage
You can run the contianer by choosing any method of your preference.

1. Docker Hub
2. Source Code

## 1. Docker Hub

Pull the image from docker hub and run its container.
```bash
docker pull shakaib/docker-lamp:18.04
docker run -itd --name docker-lamp -p 8080:80 shakaib/docker-lamp:18.04
docker exec -it docker-lamp bash
# in the container terminal check the process
ps aux
```

This command will downlaod the image from docker hub and create its container.
```bash
docker run -itd --name docker-lamp -p 8080:80 shakaib/docker-lamp:18.04 /boot
docker exec -it docker-lamp bash
# in the container terminal check the process
ps aux
```

If you see both apache and mysql processes are running then open your internet browser and access this container by using public IP address of your Docker host http://127.0.0.1:8080 
My docker host is on my PC hence I'm using localhost to access my wordpress website.

## 2. Source Code

Open your terminal and follow these instructions to checkout the source code and build the image yourself.

```bash
cd ~
git clone https://github.com/shakaib-arif/docker-lamp.git
cd docker-lamp
docker build -t docker-lamp:18.04 .
docker run -itd --name docker-lamp -p 8080:80 docker-lamp:18.04
docker exec -it docker-lamp bash
# in the container terminal check the process
ps aux
```

> **Note:** Make sure the port we are using is opened in case if there is any firewall involved. We are using port 8080 for our container, confirm if the port is opened by issuing this `netstat -tuna | grep 8080` in the terminal. If it's not open then check out this [tutorial](https://www.cyberciti.biz/faq/linux-unix-open-ports/) to open a port.


## Reference
https://github.com/shakaib-arif/runsv/

https://www.cyberciti.biz/faq/linux-unix-open-ports/

https://www.linuxjournal.com/content/bash-trap-command

https://linuxhint.com/wait_command_linux/

