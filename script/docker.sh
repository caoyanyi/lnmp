#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=script/common.sh
source "$(dirname "$0")/common.sh"
detect_os

system_user=$(first_home_user || true)
DOCKER_INSTALL_URL='https://raw.githubusercontent.com/caoyanyi/lnmp/refs/heads/master/backup/docker.sh'
MIRROR_URL='https://mirrors.ustc.edu.cn/docker-ce'

curl -fsSL "${DOCKER_INSTALL_URL}" | DOWNLOAD_URL="${MIRROR_URL}" bash -s --

if [[ -n "${system_user}" ]]; then
    gpasswd -a "${system_user}" docker || true
fi

restart_service docker
chmod a+rw /var/run/docker.sock

if ! grep -q '^vm.max_map_count=655360$' /etc/sysctl.conf; then
    echo 'vm.max_map_count=655360' >> /etc/sysctl.conf
fi
sysctl -p >/dev/null

restart_service docker
