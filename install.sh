#!/usr/bin/env bash
set -euo pipefail

RED='\033[31m'
GREEN='\033[32m'
RESET='\033[0m'

if [[ "${EUID}" -ne 0 ]]; then
    echo -e "${RED}请使用root账户执行该脚本${RESET}"
    exit 255
fi

declare -A config=(
    ["userType"]=""
    ["phpVersion"]="8.1"
    ["mysqlPwd"]="123456"
)

validate_config() {
    if [[ -z "${config[userType]}" ]]; then
        echo -e "${RED}请配置基础信息后安装${RESET}"
        exit 255
    fi
}

run_step() {
    local message=$1
    local script_path=$2
    shift 2

    echo -e "${GREEN}${message}${RESET}"
    "${script_path}" "$@"
}

install_components() {
    run_step "正在安装基础软件..." ./script/apt.sh
    run_step "正在配置Git..." ./script/git.sh
    run_step "正在安装配置Nginx..." ./script/nginx.sh
    run_step "正在安装配置MySQL..." ./script/mysql.sh "${config[mysqlPwd]}"
    run_step "正在安装配置PHP..." ./script/php.sh "${config[userType]}" "${config[phpVersion]}"
    run_step "正在进行系统优化..." ./script/optimize.sh
    run_step "正在安装Docker..." ./script/docker.sh
}

cleanup() {
    echo -e "${GREEN}安装完成，保留当前目录以便后续排障。${RESET}"
}

show_success() {
    echo -e "${GREEN}安装成功！${RESET}"
}

main() {
    validate_config
    install_components
    cleanup
    show_success
}

main "$@"
