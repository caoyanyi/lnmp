#!/usr/bin/env bash
set -euo pipefail

COMPOSE_FILE="$(dirname "$0")/docker-compose.test.yml"
COMPOSE_BIN=''
STACK_STARTED=0

init_compose_bin() {
    if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
        COMPOSE_BIN='docker compose'
    elif command -v docker-compose >/dev/null 2>&1; then
        COMPOSE_BIN='docker-compose'
    else
        echo '错误：未找到 docker compose / docker-compose' >&2
        exit 1
    fi
}

compose() {
    # shellcheck disable=SC2086
    $COMPOSE_BIN -f "$COMPOSE_FILE" "$@"
}

run_checks() {
    local svc=$1
    echo "[${svc}] 安装基础工具并执行脚本检查"
    compose exec -T "$svc" bash -lc '
      set -e
      if command -v apt-get >/dev/null 2>&1; then
        apt-get update -y -qq && apt-get install -y -qq bash ca-certificates findutils
      elif command -v dnf >/dev/null 2>&1; then
        dnf install -y -q bash ca-certificates findutils
      elif command -v yum >/dev/null 2>&1; then
        yum install -y -q bash ca-certificates findutils
      fi

      bash -n install.sh script/*.sh
      bash -lc "source script/common.sh; detect_os; echo OS=$OS_ID VER=$OS_VERSION_ID PKG=$PKG_MGR"
    '
}

cleanup() {
    if [[ "$STACK_STARTED" -eq 1 ]]; then
        compose down -v || true
    fi
}

trap cleanup EXIT

init_compose_bin
compose up -d
STACK_STARTED=1

run_checks ubuntu
run_checks debian
run_checks centos

echo 'Docker 多发行版冒烟测试完成。'
