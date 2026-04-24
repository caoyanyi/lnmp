#!/usr/bin/env bash
set -euo pipefail

echo '一些小优化...'

# 优化 Swap 空间使用
swapoff -a || true
if [[ ! -f /swapfile ]]; then
    dd if=/dev/zero of=/swapfile bs=64M count=16 status=none
    chmod 600 /swapfile
    mkswap /swapfile
fi
swapon /swapfile || true

# 优化网络参数，调整 swappiness 值（避免重复追加）
for key in vm.swappiness vm.vfs_cache_pressure net.core.somaxconn net.ipv4.tcp_max_syn_backoff \
    net.ipv4.tcp_slow_start_after_idle net.ipv4.tcp_fastopen net.ipv4.tcp_rfc1337 \
    net.ipv4.tcp_mtu_probing net.ipv4.tcp_base_mss net.ipv4.tcp_max_mss; do
    sed -i "/^${key}[[:space:]]*=/d" /etc/sysctl.conf
done

cat >> /etc/sysctl.conf <<'EOT'
vm.swappiness=10
vm.vfs_cache_pressure=50
net.core.somaxconn=65535
net.ipv4.tcp_max_syn_backoff=0
net.ipv4.tcp_slow_start_after_idle=0
net.ipv4.tcp_fastopen=3
net.ipv4.tcp_rfc1337=0
net.ipv4.tcp_mtu_probing=1
net.ipv4.tcp_base_mss=10240
net.ipv4.tcp_max_mss=16384
EOT
sysctl -p >/dev/null

# 调整系统资源限制
sed -i '/\* soft nofile 65535/d;/\* hard nofile 65535/d;/\* soft nproc 65535/d;/\* hard nproc 65535/d' /etc/security/limits.conf
cat >> /etc/security/limits.conf <<'EOT'
* soft nofile 65535
* hard nofile 65535
* soft nproc 65535
* hard nproc 65535
EOT

apt update -y -qq
apt install -y -qq preload util-linux
systemctl enable --now fstrim.timer

systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

echo '正在设置系统时区...'
ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
dpkg-reconfigure -f noninteractive tzdata

if ! grep -q '^fs.inotify.max_user_watches=8192000$' /etc/sysctl.conf; then
    echo 'fs.inotify.max_user_watches=8192000' >> /etc/sysctl.conf
fi
sysctl -w fs.inotify.max_user_watches=8192000 >/dev/null

apt autoremove -y -qq
apt autoclean -y -qq
