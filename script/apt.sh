#!/bin/bash
apt update -y -qq
apt install --reinstall ca-certificates -y -qq

# 切换清华源
echo '正在切换清华源...'
find /etc/apt/ -type f | xargs sed -i "s@http://.*archive.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g"
find /etc/apt/ -type f | xargs sed -i "s@http://.*security.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g"

if [ -f "/etc/needrestart/needrestart.conf" ];then
  sed -i "/^\#\$nrconf{restart}/c\$nrconf{restart} = 'a';" /etc/needrestart/needrestart.conf
fi

echo -e "\033[31m正在更新软件，过程较长，请耐心等待，不要退出!\033[0m"
apt update     -y -qq
apt upgrade    -y -qq
apt autoremove -y -qq
apt autoclean  -y -qq

# 基础软件
echo '正在安装基础软件...'

apt install -y -qq wget
apt install -y -qq cron
apt install -y -qq grub-pc
apt install -y -qq aptitude
apt install -y -qq ctags
apt install -y -qq cconv
apt install -y -qq exuberant-ctags
apt install -y -qq nfs-common
apt install -y -qq jq
apt install -y -qq zip lrzsz net-tools zlib1g-dev
apt install -y -qq git subversion inotify-tools gcc g++ composer
apt install -y -qq software-properties-common nginx mariadb-server
apt install -y -qq python-is-python3
snap install task --classic
