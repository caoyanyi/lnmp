#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

check_params() {
    if [[ $# -lt 2 ]]; then
        echo -e "${RED}错误：需要提供用户类型(userType)和PHP版本号(phpVersion)作为参数！${NC}" >&2
        exit 1
    fi
}

setup_php_run_dir() {
    install -d -m 755 /var/run/php
}

update_package_list() {
    echo -e "${GREEN}正在更新系统包列表...${NC}"
    apt-get update -qq
}

setup_mirror() {
    shopt -s nullglob
    local files=(/etc/apt/sources.list.d/*.list /etc/apt/sources.list.d/*.sources)
    local file
    for file in "${files[@]}"; do
        sed -i 's/ppa.launchpadcontent.net/launchpad.proxy.ustclug.org/g' "$file"
    done
    shopt -u nullglob
}

install_php_version() {
    local php_ver=$1
    local packages=(
        "php${php_ver}" "php${php_ver}-fpm" "php${php_ver}-gd" "php${php_ver}-cgi"
        "php${php_ver}-mysql" "php${php_ver}-xml" "php${php_ver}-yaml" "php${php_ver}-mbstring"
        "php${php_ver}-mcrypt" "php${php_ver}-common" "php${php_ver}-dev" "php${php_ver}-curl"
        "php${php_ver}-zip" "php${php_ver}-ldap" "php${php_ver}-intl" "php${php_ver}-xdebug"
    )

    echo -e "${GREEN}正在安装PHP ${php_ver} 和相关扩展...${NC}"
    apt install -y -qq "${packages[@]}" || true
    apt install -y -qq "php${php_ver}-json" || true
}

replace_or_append() {
    local key=$1 value=$2 file=$3
    if grep -qE "^;?${key}[[:space:]]*=" "$file"; then
        sed -i "s|^;\?${key}[[:space:]]*=.*|${key} = ${value}|" "$file"
    else
        echo "${key} = ${value}" >> "$file"
    fi
}

configure_php_fpm() {
    local php_ver=$1
    local php_ini="/etc/php/${php_ver}/fpm/php.ini"
    local pool_conf="/etc/php/${php_ver}/fpm/pool.d/www.conf"

    replace_or_append 'display_errors' 'On' "$php_ini"
    replace_or_append 'memory_limit' '1024M' "$php_ini"
    replace_or_append 'max_input_vars' '10000' "$php_ini"
    replace_or_append 'post_max_size' '100M' "$php_ini"
    replace_or_append 'upload_max_filesize' '100M' "$php_ini"

    replace_or_append 'pm.max_children' '256' "$pool_conf"
    replace_or_append 'pm.start_servers' '64' "$pool_conf"
    replace_or_append 'pm.max_spare_servers' '128' "$pool_conf"
}

main() {
    check_params "$@"

    local user_type=$1
    local php_version=$2
    local php_versions=()

    setup_php_run_dir
    add-apt-repository ppa:ondrej/php -y
    setup_mirror
    update_package_list

    case "$user_type" in
        tester)
            php_versions=(5.6 7.0 7.1 7.2 7.3 7.4 8.1 8.2 8.3)
            ;;
        dev)
            php_versions=(5.6 7.4 8.1)
            ;;
        *)
            php_versions=("$php_version")
            ;;
    esac

    local php_ver
    for php_ver in "${php_versions[@]}"; do
        install_php_version "$php_ver"

        if [[ -d "/etc/php/${php_ver}/fpm" ]]; then
            configure_php_fpm "$php_ver"
            service "php${php_ver}-fpm" restart
        else
            echo -e "${RED}警告：PHP ${php_ver} FPM配置目录不存在，已跳过配置。${NC}" >&2
        fi
    done

    if [[ -x /usr/bin/php7.4 ]]; then
        update-alternatives --set php /usr/bin/php7.4
    fi

    echo -e "${GREEN}PHP安装和配置完成！${NC}"
}

main "$@"
