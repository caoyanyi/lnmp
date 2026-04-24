#!/usr/bin/env bash
set -euo pipefail

apt update -y -qq
apt install --reinstall ca-certificates -y -qq

echo '正在切换清华源...'
while IFS= read -r file; do
    sed -i 's@http://.*archive.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g' "$file"
    sed -i 's@http://.*security.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g' "$file"
done < <(find /etc/apt/ -type f)

if [[ -f /etc/needrestart/needrestart.conf ]]; then
    sed -i "/^\#\$nrconf{restart}/c\$nrconf{restart} = 'a';" /etc/needrestart/needrestart.conf
fi

echo -e '\033[31m正在更新软件，过程较长，请耐心等待，不要退出!\033[0m'
apt update -y -qq
apt upgrade -y -qq
apt autoremove -y -qq
apt autoclean -y -qq

echo '正在安装基础软件...'
apt install -y -qq \
    wget cron grub-pc aptitude ctags cconv exuberant-ctags nfs-common jq \
    zip lrzsz net-tools zlib1g-dev git subversion inotify-tools gcc g++ \
    composer software-properties-common nginx mariadb-server python-is-python3

if ! command -v snap >/dev/null 2>&1; then
    apt install -y -qq snapd
fi

if ! command -v task >/dev/null 2>&1; then
    snap install task --classic
fi
