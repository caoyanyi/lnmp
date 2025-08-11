#!/bin/bash
systemUser=$(ls /home/ | head -1)

apt install -y -qq git

echo '正在初始化Git设置...'
git config --global core.editor        vim
git config --global http.sslVerify     false
git config --global https.sslVerify    false
git config --global credential.helper  store
git config --global core.quotepath     false
git config --global pull.rebase        true

# 模拟用户设置git记住密码
sudo -u ${systemUser} git config --global core.editor        vim
sudo -u ${systemUser} git config --global http.sslVerify     false
sudo -u ${systemUser} git config --global https.sslVerify    false
sudo -u ${systemUser} git config --global credential.helper  store
sudo -u ${systemUser} git config --global core.quotepath     false
sudo -u ${systemUser} git config --global pull.rebase        true

# 设置默认打开编辑器
echo 'export EDITOR=vim' >> /etc/profile
source /etc/profile
