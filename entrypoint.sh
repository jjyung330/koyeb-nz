#!/bin/sh

# 1. 启动伪装 Web 服务器 (使用 Python3)
# ---------------------------------------------------
mkdir -p /www
echo "Nezha Agent V1 is running..." > /www/index.html

# [修改点] 使用 python3 启动服务器，并放入后台 (&)
# --directory 指定目录，PORT 指定端口
nohup python3 -m http.server --directory /www ${PORT:-8000} >/dev/null 2>&1 &

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

# TLS 判断
TLS_BOOL="false"
if [ "$NZ_TLS" = "1" ] || [ "$NZ_TLS" = "true" ]; then
    TLS_BOOL="true"
fi

# UUID 判断
MY_UUID="${UUID:-$(cat /proc/sys/kernel/random/uuid)}"

# 写入配置
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
