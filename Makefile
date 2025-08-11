userType    = dev                  # 用户类型，dev|tester
abbrAccount :=                     # 名字首拼
realAccount :=                     # 名字全拼
wwwPath     = /data/sites          # 运行代码目录
gitPath     = /data/repo           # Git代码目录
phpVersion  = 8.1                  # 安装的PHP版本
mysqlPwd    = 123456               # MySQL的root密码
systemUser  = $(shell ls /home/ | head -1) # 系统初始用户

all:
ifneq ($(abbrAccount), )
	make apps
	make git
	make nginx
	make mysql
	make php
	make code
	make optimize
	make docker
	echo -e "\033[32m安装成功！请用浏览器访问 http://${abbrAccount}.oop.cc/loader-wizard.php 查看解密插件安装的情况。\033[0m"
else
	echo -e "\033[31m请配置基础信息后安装\033[0m"
endif

apps:
	# 切换清华源, 安装基础软件                                                                     ~
	sudo ./script/apt.sh

git:
	# Git设置
	sudo ./script/git.sh ${realAccount}

nginx:
	# 安装配置Nginx
	sudo ./script/nginx.sh ${wwwPath} ${abbrAccount} ${phpVersion}

mysql:
	# 安装配置MySQL
	sudo ./script/mysql.sh ${mysqlPwd}

php:
	# 安装配置PHP
	sudo ./script/php.sh ${userType} ${phpVersion}

code:
	# 设置代码目录
	sudo ./script/code.sh ${wwwPath} ${gitPath} ${userType} ${abbrAccount}

optimize:
	# 系统优化
	sudo ./script/optimize.sh

docker:
	# 判断是否已安装docker，如果未安装则进行安装
	sudo apt install docker.io -y
	sudo gpasswd -a ${systemUser} docker
	# 配置sonar问题
	sudo chmod a+rw /var/run/docker.sock
	sudo echo 'vm.max_map_count=655360' >> /etc/sysctl.conf
	sduo service docker restart

clean:
	echo '正在清理数据...'
	cd ../ && sudo rm -rf lnmp*
