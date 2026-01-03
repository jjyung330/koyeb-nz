FROM alpine:latest

# 安装依赖
# [修改点] 增加了 python3
RUN apk add --no-cache curl ca-certificates unzip python3

# 设置工作目录
WORKDIR /dashboard

# 下载哪吒探针 V1
RUN curl -L https://github.com/nezhahq/agent/releases/latest/download/nezha-agent_linux_amd64.zip -o agent.zip && \
    unzip agent.zip && \
    rm agent.zip && \
    chmod +x nezha-agent

# 复制启动脚本
COPY entrypoint.sh /dashboard/entrypoint.sh
RUN chmod +x /dashboard/entrypoint.sh

# 设置启动命令
ENTRYPOINT ["/dashboard/entrypoint.sh"]
