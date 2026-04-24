#!/usr/bin/env bash
set -euo pipefail

mysql_pwd=${1:-}
if [[ -z "${mysql_pwd}" ]]; then
    echo '错误：请传入 MySQL root 密码' >&2
    exit 1
fi

apt install mariadb-server -y -qq

echo '正在初始化MySQL...'

tmp_sql=$(mktemp)
sed "s/%pwd%/${mysql_pwd}/g" backup/init_mysql.sql > "${tmp_sql}"
mysql < "${tmp_sql}"
rm -f "${tmp_sql}"

sed -i 's/bind-address\(\s*\)=.*/bind-address\1= 0.0.0.0/g' /etc/mysql/mariadb.conf.d/50-server.cnf

service mysql restart
