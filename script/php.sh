#!/bin/bash

# 定义颜色常量用于输出
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# 参数验证函数
check_params() {
    if [ $# -lt 2 ]; then
        echo -e "${RED}错误：需要提供用户类型(userType)和PHP版本号(phpVersion)作为参数！${NC}"
        exit 1
    fi
}

# 函数：创建并配置PHP运行目录
setup_php_run_dir() {
    mkdir -p /var/run/php || { echo -e "${RED}无法创建PHP运行目录！${NC}" >&2; return 1; }
    chmod 755 /var/run/php || { echo -e "${RED}无法设置PHP运行目录权限！${NC}" >&2; return 1; }
}

# 函数：更新系统包列表
update_package_list() {
    echo -e "${GREEN}正在更新系统包列表...${NC}"
    apt-get update -qq || { echo -e "${RED}apt-get更新失败！${NC}" >&2; return 1; }
}

# 函数：配置清华源
setup_tuna_mirror() {
    sed -i "s/ppa.launchpadcontent.net/launchpad.proxy.ustclug.org/g"  /etc/apt/sources.list.d/*.list
    sed -i "s/ppa.launchpadcontent.net/launchpad.proxy.ustclug.org/g"  /etc/apt/sources.list.d/*.sources
}

# 函数：安装PHP版本
install_php_version() {
    local php_ver=$1
    local packages=(
        "php${php_ver}"
        "php${php_ver}-fpm"
        "php${php_ver}-gd"
        "php${php_ver}-cgi"
        "php${php_ver}-mysql"
        "php${php_ver}-xml"
        "php${php_ver}-yaml"
        "php${php_ver}-mbstring"
        "php${php_ver}-mcrypt"
        "php${php_ver}-common"
        "php${php_ver}-dev"
        "php${php_ver}-curl"
        "php${php_ver}-zip"
        "php${php_ver}-ldap"
        "php${php_ver}-intl"
        "php${php_ver}-xdebug"
    )

    echo -e "${GREEN}正在安装PHP ${php_ver} 和相关扩展...${NC}"
    apt install "${packages[@]}" -y -qq
    apt install "php${php_ver}-json" -y -qq
}

# 函数：配置PHP-FPM设置
configure_php_fpm() {
    local php_ver=$1

    # 设置内存限制和上传限制
    sed -i "/^display_errors/cdisplay_errors = On" /etc/php/${php_ver}/fpm/php.ini
    sed -i "/^memory_limit/cmemory_limit = 1024M" /etc/php/${php_ver}/fpm/php.ini
    sed -i "/^; max_input_vars/cmax_input_vars = 10000" /etc/php/${php_ver}/fpm/php.ini
    sed -i "/^;max_input_vars/cmax_input_vars = 10000" /etc/php/${php_ver}/fpm/php.ini
    sed -i "/^post_max_size/cpost_max_size = 100M" /etc/php/${php_ver}/fpm/php.ini
    sed -i "/^upload_max_filesize/cupload_max_filesize = 100M" /etc/php/${php_ver}/fpm/php.ini

    # 设置子进程限制
    sed -i "/^pm.max_children/cpm.max_children = 256" /etc/php/${php_ver}/fpm/pool.d/www.conf
    sed -i "/^pm.start_servers/cpm.start_servers = 64" /etc/php/${php_ver}/fpm/pool.d/www.conf
    sed -i "/^pm.max_spare_servers/cpm.max_spare_servers = 128" /etc/php/${php_ver}/fpm/pool.d/www.conf
}

# 主程序开始
main() {
    check_params "$@"

    local userType=$1
    local phpVersion=$2

    setup_php_run_dir
    add-apt-repository ppa:ondrej/php -y
    setup_tuna_mirror
    update_package_list

    # 定义PHP版本列表
    declare -A phpVersions
    case $userType in
        tester)
            phpVersions=(
                ["5.6"]="20131226"
                ["7.0"]="20151012"
                ["7.1"]="20160303"
                ["7.2"]="20170718"
                ["7.3"]="20180731"
                ["7.4"]="20190902"
                ["8.1"]="20210902"
                ["8.2"]="20220829"
                ["8.3"]="20230831"
            )
            ;;
        dev)
            phpVersions=(
                ["5.6"]="20131226"
                ["7.4"]="20190902"
                ["8.1"]="20210902"
            )
            ;;
        *)
            phpVersions["$phpVersion"]=""
            ;;
    esac

    # 安装指定的PHP版本
    for phpVer in "${!phpVersions[@]}"; do
        install_php_version "$phpVer"

        # 配置PHP-FPM设置
        configure_php_fpm "$phpVer"

        # 重启PHP-FPM服务
        service php${phpVer}-fpm restart || {
            echo -e "${RED}无法重启PHP ${phpVer}-FPM服务！${NC}" >&2;
            return 1;
        }
    done

    # 配置PHP命令别名
    update-alternatives --set php /usr/bin/php7.4

    echo -e "${GREEN}PHP安装和配置完成！${NC}"
}

main "$@"
