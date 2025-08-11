# LNMP 环境自动化安装脚本

这是一个用于在 Linux 系统上自动化安装和配置 Nginx + PHP + MySQL + Docker 环境的脚本集合。

## 功能特性

- 🚀 **一键安装**：自动化安装完整的 LNMP 开发环境
- 🔧 **多版本支持**：支持多个 PHP 版本（5.6, 7.0, 7.1, 7.2, 7.3, 7.4, 8.1, 8.2, 8.3）
- 🐳 **Docker 集成**：自动安装和配置 Docker 环境
- ⚡ **性能优化**：包含系统性能优化配置
- 🛡️ **安全配置**：基础安全设置和优化
- 🌍 **镜像源优化**：自动切换到清华镜像源，提升下载速度

## 系统要求

- Linux 系统（Ubuntu/Debian 推荐）
- Root 权限
- 网络连接

## 安装方式

### 方式一：使用 Makefile（推荐）

1. 编辑 `Makefile` 配置文件，设置以下参数：
   ```makefile
   userType    = dev                  # 用户类型：dev|tester
   abbrAccount = yourname             # 名字首拼（用于域名）
   realAccount = yourfullname         # 名字全拼
   wwwPath     = /data/sites          # 网站根目录
   gitPath     = /data/repo           # Git 代码目录
   phpVersion  = 8.1                  # 默认 PHP 版本
   mysqlPwd    = 123456               # MySQL root 密码
   ```

2. 执行安装：
   ```bash
   make all
   ```

### 方式二：使用主安装脚本

1. 编辑 `install.sh` 中的配置：
   ```bash
   config=(
       ["userType"]="dev"              # 用户类型：dev|tester
       ["phpVersion"]="8.1"           # PHP 版本
       ["mysqlPwd"]="123456"          # MySQL 密码
   )
   ```

2. 运行安装脚本：
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

## 用户类型说明

### dev（开发者）
- 默认安装 PHP 版本：5.6, 7.4, 8.1
- 适合日常开发使用

### tester（测试人员）
- 默认安装 PHP 版本：5.6, 7.0, 7.1, 7.2, 7.3, 7.4, 8.1, 8.2, 8.3
- 适合需要多版本测试的场景

### 其他类型
- 只安装指定的单个 PHP 版本

## 安装组件

### 基础组件
- **Nginx**：Web 服务器，配置了 100M 文件上传限制
- **MySQL (MariaDB)**：数据库服务器，支持远程连接
- **PHP**：支持多版本共存，包含常用扩展
- **Docker**：容器化平台

### 开发工具
- Git（配置了国内镜像加速）
- Composer（PHP 依赖管理）
- SSH、SCP、RZ/SZ 等工具
- Python 3 和相关工具

### 系统优化
- 网络参数优化
- 文件描述符限制调整
- Swap 空间优化
- 系统服务优化
- 时区设置为上海

## 目录结构

```
lnmp/
├── Makefile              # Make 构建文件
├── install.sh            # 主安装脚本
├── script/               # 安装脚本目录
│   ├── apt.sh           # APT 源配置和基础软件安装
│   ├── nginx.sh         # Nginx 安装配置
│   ├── mysql.sh         # MySQL 安装配置
│   ├── php.sh           # PHP 多版本安装
│   ├── docker.sh        # Docker 安装配置
│   ├── git.sh           # Git 配置
│   └── optimize.sh      # 系统优化
└── backup/              # 备份文件
    ├── init_mysql.sql   # MySQL 初始化脚本
    └── adminer.php      # 数据库管理工具
```

## 配置说明

### PHP 配置
- 内存限制：1024M
- 上传文件大小：100M
- POST 最大大小：100M
- 最大输入变量：10000
- 显示错误：开启

### MySQL 配置
- 支持远程连接
- 默认端口：3306
- 初始化后设置 root 密码

### Nginx 配置
- 客户端最大请求体：100M
- 支持多 PHP 版本切换

## 使用说明

### 启动/停止服务
```bash
# Nginx
service nginx start/stop/restart

# MySQL
service mysql start/stop/restart

# PHP-FPM (多版本)
service php5.6-fpm start/stop/restart
service php7.4-fpm start/stop/restart
service php8.1-fpm start/stop/restart

# Docker
service docker start/stop/restart
```

### PHP 版本切换
```bash
# 切换默认 PHP 版本
update-alternatives --set php /usr/bin/php7.4
```

## 安全注意事项

1. **密码安全**：安装后请立即修改 MySQL 默认密码
2. **防火墙**：根据需要配置防火墙规则
3. **权限控制**：确保网站目录权限正确设置
4. **远程访问**：谨慎开启 MySQL 远程访问

## 故障排除

### 常见问题
1. **权限问题**：确保脚本以 root 权限运行
2. **网络问题**：检查网络连接和镜像源配置
3. **端口冲突**：确保 80、3306 等端口未被占用
4. **服务启动失败**：检查配置文件语法

### 日志查看
```bash
# Nginx 日志
tail -f /var/log/nginx/error.log

# MySQL 日志
tail -f /var/log/mysql/error.log

# PHP-FPM 日志
tail -f /var/log/php5.6-fpm.log
tail -f /var/log/php7.4-fpm.log
tail -f /var/log/php8.1-fpm.log
```

## 贡献

欢迎提交 Issue 和 Pull Request 来改进这个项目。

## 许可证

本项目采用 MIT 许可证。

## 免责声明

本脚本仅供学习和开发使用。在生产环境使用前，请充分测试并根据实际需求调整配置。使用者需自行承担使用风险。