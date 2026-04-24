#!/usr/bin/env bash
set -euo pipefail

apt install -y -qq software-properties-common nginx

if ! grep -qE '^[[:space:]]*client_max_body_size[[:space:]]+100m;' /etc/nginx/nginx.conf; then
    sed -i '/types_hash_max_size/a\        client_max_body_size 100m;' /etc/nginx/nginx.conf
fi
