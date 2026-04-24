#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=script/common.sh
source "$(dirname "$0")/common.sh"
detect_os

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

replace_or_append() {
    local key=$1 value=$2 file=$3
    if grep -qE "^;?${key}[[:space:]]*=" "$file"; then
        sed -i "s|^;\?${key}[[:space:]]*=.*|${key} = ${value}|" "$file"
    else
        echo "${key} = ${value}" >> "$file"
    fi
}

configure_php_fpm() {
    local php_ini=$1
    local pool_conf=$2

    replace_or_append 'display_errors' 'On' "$php_ini"
    replace_or_append 'memory_limit' '1024M' "$php_ini"
    replace_or_append 'max_input_vars' '10000' "$php_ini"
    replace_or_append 'post_max_size' '100M' "$php_ini"
    replace_or_append 'upload_max_filesize' '100M' "$php_ini"

    replace_or_append 'pm.max_children' '256' "$pool_conf"
    replace_or_append 'pm.start_servers' '64' "$pool_conf"
    replace_or_append 'pm.max_spare_servers' '128' "$pool_conf"
}

install_php_debian() {
    local php_ver=$1
    pkg_install software-properties-common
    add-apt-repository ppa:ondrej/php -y
    pkg_update

    local packages=(
        "php${php_ver}" "php${php_ver}-fpm" "php${php_ver}-gd" "php${php_ver}-cgi"
        "php${php_ver}-mysql" "php${php_ver}-xml" "php${php_ver}-yaml" "php${php_ver}-mbstring"
        "php${php_ver}-mcrypt" "php${php_ver}-common" "php${php_ver}-dev" "php${php_ver}-curl"
        "php${php_ver}-zip" "php${php_ver}-ldap" "php${php_ver}-intl" "php${php_ver}-xdebug"
    )
    pkg_install "${packages[@]}" || true
    pkg_install "php${php_ver}-json" || true

    local php_ini="/etc/php/${php_ver}/fpm/php.ini"
    local pool_conf="/etc/php/${php_ver}/fpm/pool.d/www.conf"
    if [[ -f "$php_ini" && -f "$pool_conf" ]]; then
        configure_php_fpm "$php_ini" "$pool_conf"
        restart_service "php${php_ver}-fpm"
    fi
}

install_php_rhel() {
    local php_ver=$1
    pkg_install epel-release || true

    if [[ -f /etc/yum.repos.d/remi.repo ]]; then
        :
    else
        local remi_rpm="https://rpms.remirepo.net/enterprise/remi-release-$(rpm -E '%{rhel}').rpm"
        pkg_install "${remi_rpm}" || true
    fi

    if command_exists dnf; then
        dnf module reset php -y -q || true
        dnf module enable "php:remi-${php_ver//./}" -y -q || true
    fi

    pkg_install php php-fpm php-cli php-common php-mysqlnd php-gd php-xml php-mbstring php-intl php-pecl-zip || true

    local php_ini='/etc/php.ini'
    local pool_conf='/etc/php-fpm.d/www.conf'
    if [[ -f "$php_ini" && -f "$pool_conf" ]]; then
        configure_php_fpm "$php_ini" "$pool_conf"
    fi
    restart_service php-fpm
}

main() {
    check_params "$@"

    local user_type=$1
    local php_version=$2
    local php_versions=()

    setup_php_run_dir

    case "$user_type" in
        tester)
            php_versions=(5.6 7.0 7.1 7.2 7.3 7.4 8.1)
            ;;
        dev)
            php_versions=(7.4 8.1)
            ;;
        *)
            php_versions=("$php_version")
            ;;
    esac

    local php_ver
    for php_ver in "${php_versions[@]}"; do
        echo -e "${GREEN}正在安装PHP ${php_ver}...${NC}"
        if is_debian_family; then
            install_php_debian "$php_ver"
        else
            install_php_rhel "$php_ver"
        fi
    done

    if [[ -x /usr/bin/php7.4 ]]; then
        update-alternatives --set php /usr/bin/php7.4 || true
    fi

    echo -e "${GREEN}PHP安装和配置完成！${NC}"
}

main "$@"
