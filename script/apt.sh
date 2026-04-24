#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=script/common.sh
source "$(dirname "$0")/common.sh"
detect_os

configure_china_mirror_if_needed() {
    if ! is_debian_family; then
        return 0
    fi

    echo '正在切换清华源...'
    while IFS= read -r file; do
        sed -i 's@http://.*archive.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g' "$file"
        sed -i 's@http://.*security.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g' "$file"
        sed -i 's@http://deb.debian.org@https://mirrors.tuna.tsinghua.edu.cn@g' "$file"
    done < <(find /etc/apt/ -type f)

    if [[ -f /etc/needrestart/needrestart.conf ]]; then
        sed -i "/^\#\$nrconf{restart}/c\$nrconf{restart} = 'a';" /etc/needrestart/needrestart.conf
    fi
}

install_base_packages() {
    if is_debian_family; then
        pkg_install ca-certificates
        pkg_install wget cron git subversion inotify-tools gcc g++ jq zip net-tools
        pkg_install zlib1g-dev nginx mariadb-server software-properties-common
        pkg_install python3 python-is-python3 lrzsz
    else
        pkg_install ca-certificates
        pkg_install wget cronie git subversion inotify-tools gcc gcc-c++ jq zip net-tools
        pkg_install zlib-devel nginx mariadb-server
        pkg_install python3 which tar
    fi
}

main() {
    configure_china_mirror_if_needed

    echo -e '\033[31m正在更新软件，过程较长，请耐心等待，不要退出!\033[0m'
    pkg_update
    pkg_upgrade

    echo '正在安装基础软件...'
    install_base_packages
    pkg_remove_unused
}

main "$@"
