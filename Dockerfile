# Start with centos7 base
FROM centos:7


# Start with basic nginx installation steps 

# Install nginx
RUN yum -y install epel-release

RUN yum -y install nginx


# Open ports in the firewall

# RUN yum -y install firewalld
# I found firewalld is not installed by default on the docker container?

# RUN firewall-cmd --add-interface=docker0 --permanent

# RUN firewall-cmd --add-service=http --permanent

# RUN firewall-cmd --add-service=https --permanent

# RUN firewall-cmd --reload

# Expose the ports in Docker https://docs.docker.com/engine/reference/builder/#expose

EXPOSE 80/tcp

EXPOSE 443/tcp

RUN mkdir -m 700 /etc/ssl/private

ADD nginx-selfsigned.key /etc/ssl/private/nginx-selfsigned.key
ADD nginx-selfsigned.crt /etc/ssl/certs/nginx-selfsigned.crt
ADD dhparam.pem /etc/ssl/certs/dhparam.pem
ADD ssl.conf /etc/nginx/conf.d/ssl.conf


CMD nginx -g 'daemon off;'

# Process:

# First, I started with the centos7 image and did a standard install of NGINX with YUM.
# I ran into an issue with systemd starting nginx with a Failed to get D-Bus connection: Operation not permitted error
# After googling the error I found the best practice is to not use systemd inside a container and to execute the daemon directly

# Tried to determine location of executable with a RUN which nginx, however it looks like which is not installed on the docker image.  In the end I spun up a VM locally and tried installing nginx and looked at the systemd unit file from there and copied it in (so as not to assume it was in /usr/bin/nginx, which it wasn't, it was in sbin).  I will continue to use this VM to tinker around and test when needed

# To set up the SSL certificate, I followed the guide at https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-on-centos-7 and created the SSL certificate in the local directory that I was creating the dockerfile in, and added the ADD statements to put them in the locations specified in the guide


# After trying to get firewalld to work in the container - I realized since docker is only exporting 2 ports, that there shouldn't be a need to run the firewall inside the image either, so I am going to remove the firewalld entries


# Tried a couple of times to get the container to run, I was issuing the 'docker run <id>' command, but nothing was showing up in 'docker ps'.  Short amount of googling I found https://www.digitalocean.com/community/tutorials/how-to-run-nginx-in-a-docker-container-on-ubuntu-14-04 which indicated I needed to add a command at the end, which finally got it to run with docker run -d nginx -g 'daemon off';.  Then, after reading further in the docker documentation, realized I could put this in the file with CMD.  Then, as an added bonus, despite thinking I had set the CMD parameter properly, I could not get the container to stay running after launch.  I banged my head against it for a few minutes before realizing I wasn't running the container that I was building, once using the proper container ID in the docker run -d command, it worked perfectly fine.  PEBCAK!  After defeating my own failures, nginx is properly serving on ports 80 and 443 on the docker0 interface!

