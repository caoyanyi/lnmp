#!/usr/bin/env bash
set -euo pipefail

OS_ID=''
OS_VERSION_ID=''
OS_FAMILY=''
PKG_MGR=''

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

detect_os() {
    if [[ -r /etc/os-release ]]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        OS_ID=${ID:-}
        OS_VERSION_ID=${VERSION_ID:-}
        OS_FAMILY=${ID_LIKE:-}
    else
        echo '错误：无法识别系统发行版（缺少 /etc/os-release）' >&2
        exit 1
    fi

    if command_exists apt-get; then
        PKG_MGR='apt'
    elif command_exists dnf; then
        PKG_MGR='dnf'
    elif command_exists yum; then
        PKG_MGR='yum'
    else
        echo '错误：不支持的包管理器（仅支持 apt/dnf/yum）' >&2
        exit 1
    fi
}

is_debian_family() {
    [[ "$PKG_MGR" == 'apt' ]]
}

is_rhel_family() {
    [[ "$PKG_MGR" == 'dnf' || "$PKG_MGR" == 'yum' ]]
}

pkg_update() {
    case "$PKG_MGR" in
        apt) apt-get update -y -qq ;;
        dnf) dnf makecache -y -q ;;
        yum) yum makecache -y -q ;;
    esac
}

pkg_upgrade() {
    case "$PKG_MGR" in
        apt) apt-get upgrade -y -qq ;;
        dnf) dnf upgrade -y -q ;;
        yum) yum update -y -q ;;
    esac
}

pkg_install() {
    case "$PKG_MGR" in
        apt) apt-get install -y -qq "$@" ;;
        dnf) dnf install -y -q "$@" ;;
        yum) yum install -y -q "$@" ;;
    esac
}

pkg_remove_unused() {
    case "$PKG_MGR" in
        apt)
            apt-get autoremove -y -qq
            apt-get autoclean -y -qq
            ;;
        dnf) dnf autoremove -y -q || true ;;
        yum) yum autoremove -y -q || true ;;
    esac
}

restart_service() {
    local svc=$1
    if command_exists systemctl; then
        systemctl restart "$svc"
    else
        service "$svc" restart
    fi
}

enable_now_service() {
    local svc=$1
    if command_exists systemctl; then
        systemctl enable --now "$svc"
    else
        service "$svc" start
    fi
}

first_home_user() {
    find /home -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | head -n 1
}
