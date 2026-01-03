#!/bin/sh

# 1. 启动伪装 Web 服务器 (Python3)
# ---------------------------------------------------
# 必须保留这个，否则 Koyeb 会报错
mkdir -p /www
echo "Nezha Agent V1 is running..." > /www/index.html
nohup python3 -m http.server --directory /www ${PORT:-8000} >/dev/null 2>&1 &
echo "Fake Web Server started on port ${PORT:-8000}"

# 2. 检查必要变量
# ---------------------------------------------------
if [ -z "$NZ_CLIENT_SECRET" ]; then
    echo "Error: NZ_CLIENT_SECRET is missing!"
    exit 1
fi

# 3. 生成 V1 配置文件 (config.yml)
# ---------------------------------------------------
echo "Generating V1 config.yml..."

# 写入配置文件
# 直接使用你提供的变量名
cat > /dashboard/config.yml <<EOF
server: ${NZ_SERVER}
client_secret: ${NZ_CLIENT_SECRET}
uuid: ${NZ_UUID}
tls: ${NZ_TLS}
debug: false
disable_auto_update: true
disable_command_execute: false
disable_force_update: true
report_delay: 1
EOF

# 4. 启动 Agent
# ---------------------------------------------------
echo "Starting Nezha Agent V1..."
/dashboard/nezha-agent -c /dashboard/config.yml
