#!/usr/bin/env bash
set -euo pipefail

system_user=$(find /home -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | head -n 1)
DOCKER_INSTALL_URL='https://raw.githubusercontent.com/caoyanyi/lnmp/refs/heads/master/backup/docker.sh'
MIRROR_URL='https://mirrors.ustc.edu.cn/docker-ce'

curl -fsSL "${DOCKER_INSTALL_URL}" | DOWNLOAD_URL="${MIRROR_URL}" bash -s --

if [[ -n "${system_user}" ]]; then
    gpasswd -a "${system_user}" docker
fi

service docker restart
chmod a+rw /var/run/docker.sock

if ! grep -q '^vm.max_map_count=655360$' /etc/sysctl.conf; then
    echo 'vm.max_map_count=655360' >> /etc/sysctl.conf
fi
sysctl -p >/dev/null

service docker restart
