#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=script/common.sh
source "$(dirname "$0")/common.sh"
detect_os

mysql_pwd=${1:-}
if [[ -z "${mysql_pwd}" ]]; then
    echo '错误：请传入 MySQL root 密码' >&2
    exit 1
fi

if is_debian_family; then
    pkg_install mariadb-server
else
    pkg_install mariadb-server mariadb
fi

echo '正在初始化MySQL...'

tmp_sql=$(mktemp)
sed "s/%pwd%/${mysql_pwd}/g" backup/init_mysql.sql > "${tmp_sql}"
mysql < "${tmp_sql}"
rm -f "${tmp_sql}"

if [[ -f /etc/mysql/mariadb.conf.d/50-server.cnf ]]; then
    sed -i 's/bind-address\(\s*\)=.*/bind-address\1= 0.0.0.0/g' /etc/mysql/mariadb.conf.d/50-server.cnf
elif [[ -f /etc/my.cnf.d/mariadb-server.cnf ]]; then
    sed -i 's/^bind-address\s*=.*/bind-address=0.0.0.0/g' /etc/my.cnf.d/mariadb-server.cnf
elif [[ -f /etc/my.cnf ]]; then
    grep -q '^bind-address=' /etc/my.cnf && \
        sed -i 's/^bind-address\s*=.*/bind-address=0.0.0.0/g' /etc/my.cnf || \
        echo 'bind-address=0.0.0.0' >> /etc/my.cnf
fi

restart_service mariadb || restart_service mysql
