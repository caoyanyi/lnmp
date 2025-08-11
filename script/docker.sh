#!/bin/bash

systemUser=$(ls /home/ | head -1)

# 判断是否已安装docker，如果未安装则进行安装
DOCKER_INSTALL_URL="https://github.com/caoyanyi/lnmp/backup/docker.sh"
MIRROR_URL="https://mirrors.ustc.edu.cn/docker-ce"
curl -fsSL $DOCKER_INSTALL_URL  | DOWNLOAD_URL=$MIRROR_URL bash -x  -

gpasswd -a ${systemUser} docker
# 配置sonar问题
service docker restart
chmod a+rw /var/run/docker.sock
echo 'vm.max_map_count=655360' >> /etc/sysctl.conf
service docker restart
