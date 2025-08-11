#!/bin/bash

# 定义颜色常量
RED='\033[31m'
GREEN='\033[32m'
RESET='\033[0m'

# 检查root权限
if [ "$(whoami)" != "root" ]; then
    echo -e "${RED}请使用root账户执行该脚本${RESET}"
    exit 255
fi

# 定义配置变量
declare -A config
config=(
    ["userType"]=""    # 用户类型，dev|tester，dev默认安装php5.6/7.4/8.1，tester默认安装php5.6/7.0/7.1/7.2/7.3/7.4/8.1，其他内容默认安装下面配置的版本
    ["phpVersion"]="8.1"  # 安装的PHP版本
    ["mysqlPwd"]="123456" # MySQL的root密码
)

# 函数定义
validate_config() {
    if [ -z "${config["userType"]}" ]; then
        echo -e "${RED}请配置基础信息后安装${RESET}"
        exit 255
    fi
}

install_components() {
    dpkg-reconfigure unattended-upgrades

    echo -e "${GREEN}正在安装基础软件...${GREEN}"
    ./script/apt.sh

    echo -e "${GREEN}正在配置Git...${GREEN}"
    ./script/git.sh

    echo -e "${GREEN}正在安装配置Nginx...${GREEN}"
    ./script/nginx.sh

    echo -e "${GREEN}正在安装配置MySQL...${GREEN}"
    ./script/mysql.sh "${config["mysqlPwd"]}"

    echo -e "${GREEN}正在安装配置PHP...${GREEN}"
    ./script/php.sh "${config["userType"]}" "${config["phpVersion"]}"

    echo -e "${GREEN}正在进行系统优化...${GREEN}"
    ./script/optimize.sh

    echo -e "${GREEN}正在安装Docker...${GREEN}"
    ./script/docker.sh
}

cleanup() {
    echo -e "${GREEN}正在清理数据...${GREEN}"
    cd ../ && sudo rm -rf lnmp*
}

show_success() {
    echo -e "${GREEN}安装成功！${RESET}"
}

# 主程序执行
main() {
    validate_config
    replace_file
    install_components
    cleanup
    show_success
}

# 执行主程序
main
