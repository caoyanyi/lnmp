#!/usr/bin/env bash
set -euo pipefail

system_user=$(find /home -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | head -n 1)

apt install -y -qq git

echo '正在初始化Git设置...'

git config --global core.editor vim
git config --global http.sslVerify false
git config --global https.sslVerify false
git config --global credential.helper store
git config --global core.quotepath false
git config --global pull.rebase true

if [[ -n "${system_user}" ]]; then
    sudo -u "${system_user}" git config --global core.editor vim
    sudo -u "${system_user}" git config --global http.sslVerify false
    sudo -u "${system_user}" git config --global https.sslVerify false
    sudo -u "${system_user}" git config --global credential.helper store
    sudo -u "${system_user}" git config --global core.quotepath false
    sudo -u "${system_user}" git config --global pull.rebase true
fi

if ! grep -q '^export EDITOR=vim$' /etc/profile; then
    echo 'export EDITOR=vim' >> /etc/profile
fi
