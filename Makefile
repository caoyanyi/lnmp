userType   = dev    # 用户类型，dev|tester，dev默认安装php5.6/7.4/8.1，tester默认安装php5.6/7.0/7.1/7.2/7.3/7.4/8.1，其他内容默认安装下面配置的版本
phpVersion = 8.1    # 安装的PHP版本
mysqlPwd   = 123456 # MySQL的root密码

all:
	make apps
	make git
	make nginx
	make mysql
	make php
	make docker
	# make optimize
	make clean
	echo -e "\033[32m安装成功！\033[0m"

apps:
	# 切换清华源, 安装基础软件                                                                     ~
	sudo ./script/apt.sh

git:
	# Git设置
	sudo ./script/git.sh

nginx:
	# 安装配置Nginx
	sudo ./script/nginx.sh

mysql:
	# 安装配置MySQL
	sudo ./script/mysql.sh ${mysqlPwd}

php:
	# 安装配置PHP
	sudo ./script/php.sh ${userType} ${phpVersion}

optimize:
	# 系统优化
	sudo ./script/optimize.sh

docker:
	sudo ./script/docker.sh

clean:
	echo '正在清理数据...'
	cd ../ && sudo rm -rf lnmp*