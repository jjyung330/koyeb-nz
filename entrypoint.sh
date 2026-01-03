#!/bin/sh

# 1. 启动伪装 Web 服务器 (应付 Koyeb 健康检查)
mkdir -p /www
echo "Nezha Agent V1 is running..." > /www/index.html
# $PORT 是 Koyeb 自动分配的 (默认 8000)，必须监听它
httpd -p ${PORT:-8000} -h /www
echo "Fake Web Server started on port ${PORT:-8000}"

# 2. 现场生成 V1 配置文件 (config.yml)
# V1 必须使用配置文件，不能直接用命令行传参
echo "Generating V1 config.yml..."

# 如果面板开启了 HTTPS/TLS，TLS 设置为 true，否则 false
TLS_BOOL="false"
if [ "$NZ_TLS" = "1" ] || [ "$NZ_TLS" = "true" ]; then
    TLS_BOOL="true"
fi

cat > /dashboard/config.yml <<EOF
server: ${NZ_SERVER}:${NZ_PORT}
client_secret: ${NZ_KEY}
tls: ${TLS_BOOL}
debug: false
disable_auto_update: true
disable_command_execute: false
disable_force_update: true
report_delay: 1
EOF

# 3. 启动哪吒 Agent V1
echo "Starting Nezha Agent V1..."
# V1 启动命令通常很简单，指向配置文件即可
/dashboard/nezha-agent -c /dashboard/config.yml
