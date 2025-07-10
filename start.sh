#!/bin/bash

# --- 配置 ---
# 从环境变量获取VPN凭据和服务器信息
# 这些变量需要在 `docker run` 时传入
VPN_SERVER=${VPN_SERVER:?"VPN_SERVER 环境变量未设置"}
VPN_PASSWORD=${VPN_PASSWORD:?"VPN_PASSWORD 环境变量未设置"}

VPN_USER_AGENT=${VPN_USER_AGENT:-"AnyConnect Linux_64 4.7.00136"}
VPN_VERSION_STRING=${VPN_VERSION_STRING:-"4.7.00136"}
VPN_PROTOCOL=${VPN_PROTOCOL:-"anyconnect"} # 默认为 anyconnect, 可以是 gp, pulse 等

SOCKS_PORT=${SOCKS_PORT:-"1080"}

# --- 进程管理 ---
# 设置 trap 以在接收到 SIGTERM 或 SIGINT 时优雅地关闭子进程
trap 'kill -TERM $PID1 $PID2' TERM INT

# --- 启动 OpenConnect ---
# -b: 后台运行
# --protocol: 指定 VPN 协议
# --user: 用户名
# --passwd-on-stdin: 从标准输入读取密码，更安全
# --script /bin/true:  【关键】不执行任何路由修改脚本！
echo "Starting OpenConnect..."
echo "${VPN_PASSWORD}" | openconnect -b \
    --protocol=${VPN_PROTOCOL} \
    --cookie-on-stdin \
    --useragent="\"${VPN_USER_AGENT}\"" \
    --version-string="${VPN_VERSION_STRING}" \
    --interface=tunopen \
    ${VPN_SERVER}

# 获取 OpenConnect 的进程 ID
PID1=$!
echo "OpenConnect started with PID ${PID1}"

# 等待 tunopen 接口出现，最多等待15秒
echo "Waiting for tunopen interface to be ready..."
for i in {1..15}; do
    if ip addr show tunopen &> /dev/null; then
        echo "tunopen interface is up."
        break
    fi
    echo "Waiting... (${i}s)"
    sleep 1
done

if ! ip addr show tunopen &> /dev/null; then
    echo "Error: tunopen interface did not appear after 15 seconds. Exiting."
    kill -TERM $PID1
    exit 1
fi

# --- 启动 gost ---
echo "Starting gost on port ${SOCKS_PORT}..."
gost -L "socks5://:${SOCKS_PORT}"
# 获取 gost 的进程 ID
PID2=$!
echo "gost started with PID ${PID2}"

# 等待任一进程退出。wait -n 需要 bash 4.3+，这里用 wait $PID1 $PID2 兼容性更好
wait $PID1 $PID2