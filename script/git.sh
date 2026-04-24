#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=script/common.sh
source "$(dirname "$0")/common.sh"
detect_os

system_user=$(first_home_user || true)
pkg_install git

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
