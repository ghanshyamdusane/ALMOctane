#!/bin/bash
######## This script is intended to install and deploy the ALMOctane on docker  ########
######## This script is created and maintained by Ghanshyam Dusane #####################
#variables
ip=$(hostname -i)
#sleep for 2 min.
sleep 2m
sudo setenforce 0
sudo yum install docker wget --enablerepo=* -y
systemctl start docker.service
systemctl enable docker.service
sudo curl -L https://github.com/docker/compose/releases/download/1.21.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo mkdir /home/octane
cd /home/octane
wget https://s3.ap-south-1.amazonaws.com/almoctane-docker/cleanup.sh
wget https://s3.ap-south-1.amazonaws.com/almoctane-docker/docker-compose.yml
wget https://s3.ap-south-1.amazonaws.com/almoctane-docker/almoctane_reboot.sh
echo "@reboot sh /home/octane/almoctane_reboot.sh" | tee -a /var/spool/cron/root
systemctl restart crond.service
echo -e "
ADMIN_PASSWORD=Pass@1234567
APP_URL=http://$ip:8080
" >  /home/octane/octane.env
echo -e "
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
SELINUX=permissive
# SELINUXTYPE= can take one of three two values:
#     targeted - Targeted processes are protected,
#     minimum - Modification of targeted policy. Only selected processes are protected.
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted
" > /etc/selinux/config
docker-compose up > /var/log/octane_docker.log
