#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=script/common.sh
source "$(dirname "$0")/common.sh"
detect_os

if is_debian_family; then
    pkg_install software-properties-common nginx
else
    pkg_install nginx
fi

if ! grep -qE '^[[:space:]]*client_max_body_size[[:space:]]+100m;' /etc/nginx/nginx.conf; then
    sed -i '/types_hash_max_size/a\        client_max_body_size 100m;' /etc/nginx/nginx.conf
fi

restart_service nginx
