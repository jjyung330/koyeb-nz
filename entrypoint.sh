#!/bin/sh

# 1. 启动伪装 Web 服务器 (应付 Koyeb)
mkdir -p /www
echo "Nezha Agent V1 is running..." > /www/index.html
httpd -p ${PORT:-8000} -h /www
echo "Fake Web Server started on port ${PORT:-8000}"

# 2. 检查必要变量
if [ -z "$NZ_KEY" ]; then
    echo "Error: NZ_KEY (Client Secret) is missing!"
    exit 1
fi

# 3. 生成 V1 配置文件 (config.yml)
echo "Generating V1 config.yml..."

# 处理 TLS (HTTPS)
TLS_BOOL="false"
if [ "$NZ_TLS" = "1" ] || [ "$NZ_TLS" = "true" ]; then
    TLS_BOOL="true"
fi

# 生成配置文件
# 注意：这里同时写入了 client_secret 和 uuid
# 如果你没有在环境变量提供 UUID，脚本会自动生成一个，保证固定
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
echo "Starting Nezha Agent V1..."
/dashboard/nezha-agent -c /dashboard/config.yml
