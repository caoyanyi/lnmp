#!/bin/bash

mysqlPwd=$1
runDir=$(pwd)
apt install mariadb-server -y -qq

# mariadb设置密码登录
echo '正在初始化MySQL...'

sed -i "s/%pwd%/${mysqlPwd}/g" backup/init_mysql.sql
mysql < backup/init_mysql.sql

# 开启远程连接 MySQL
sed -i "s/bind-address\(\s*\)=.*/bind-address\1= 0.0.0.0/g" /etc/mysql/mariadb.conf.d/50-server.cnf

service mysql restart
