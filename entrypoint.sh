#!/bin/sh

# 1. 启动伪装 Web 服务器
# ---------------------------------------------------
mkdir -p /www
echo "Nezha Agent V1 is running..." > /www/index.html

# [关键修改] 使用 busybox httpd，防止找不到命令
busybox httpd -p ${PORT:-8000} -h /www

echo "Fake Web Server started on port ${PORT:-8000}"


# 2. 检查必要变量
# ---------------------------------------------------
if [ -z "$NZ_KEY" ]; then
    echo "Error: NZ_KEY (Client Secret) is missing!"
    exit 1
fi


# 3. 生成 V1 配置文件 (config.yml)
# ---------------------------------------------------
echo "Generating V1 config.yml..."

# 处理 TLS (HTTPS)
TLS_BOOL="false"
if [ "$NZ_TLS" = "1" ] || [ "$NZ_TLS" = "true" ]; then
    TLS_BOOL="true"
fi

# 生成配置文件
# 优先使用环境变量 UUID，如果没有则自动生成一个
MY_UUID="${UUID:-$(cat /proc/sys/kernel/random/uuid)}"

cat > /dashboard/config.yml <<EOF
server: ${NZ_SERVER}:${NZ_PORT}
client_secret: ${NZ_KEY}
uuid: ${MY_UUID}
tls: ${TLS_BOOL}
debug: false
disable_auto_update: true
disable_command_execute: false
disable_force_update: true
report_delay: 1
EOF

echo "Config generated with UUID: ${MY_UUID}"


# 4. 启动 Agent
# ---------------------------------------------------
echo "Starting Nezha Agent V1..."
/dashboard/nezha-agent -c /dashboard/config.yml
