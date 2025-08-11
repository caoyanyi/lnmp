#!/bin/bash

apt install -y -qq software-properties-common nginx

# 设置Nginx附件大小限制为100M
# # 检查是否已经存在该配置，然后再添加
grep -qE '^[\t ]*client_max_body_size[^\S\n]*100m' /etc/nginx/nginx.conf || sed -i '/types_hash_max_size/a \        client_max_body_size 100m;' /etc/nginx/nginx.conf
