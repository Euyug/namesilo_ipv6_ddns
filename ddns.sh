#!/bin/bash

# 读取配置文件
CONFIG_FILE="./config.json"
API_KEY=$(grep -oP '"API_KEY":\s*"\K[^"]*' $CONFIG_FILE)
DOMAIN=$(grep -oP '"DOMAIN":\s*"\K[^"]*' $CONFIG_FILE)
HOSTNAME=$(grep -oP '"HOSTNAME":\s*"\K[^"]*' $CONFIG_FILE)
API_URL=$(grep -oP '"API_URL":\s*"\K[^"]*' $CONFIG_FILE)
rrid_URL=$(grep -oP '"rrid_URL":\s*"\K[^"]*' $CONFIG_FILE)
NETWORK_INTERFACE=$(grep -oP '"NETWORK_INTERFACE":\s*"\K[^"]*' $CONFIG_FILE)
TARGET_VALUE="${HOSTNAME}.${DOMAIN}"
# echo "API_KEY: $API_KEY"
# echo "DOMAIN: $DOMAIN"
# echo "HOSTNAME: $HOSTNAME"
# echo "API_URL: $API_URL"
# echo "rrid_URL: $rrid_URL"
# echo "NETWORK_INTERFACE: $NETWORK_INTERFACE"
# echo "TARGET_VALUE: $TARGET_VALUE"
# Function to update DNS record
update_dns_record() {
    # 获取rrid
    #获取响应
response=$(curl -s "${rrid_URL}?version=1&type=xml&key=${API_KEY}&domain=${DOMAIN}")

# 使用grep提取包含目标host值的<resource_record>段
record=$(echo "$response" | grep -oP "<resource_record>.*?</resource_record>" | grep "$TARGET_VALUE")

if [ -z "$record" ]; then
    echo "未找到目标host值为 $TARGET_VALUE 的记录"
    exit 1
fi

# 使用sed提取<record_id>值
RRID=$(echo "$record" | sed -n 's/.*<record_id>\(.*\)<\/record_id>.*/\1/p')

echo "host:$TARGET_VALUE 的rrid为: $RRID"
    
    # 获取当前的公共 IPv6 地址
    CURRENT_IPv6=$(ip -6 addr show dev $NETWORK_INTERFACE | grep inet6 | grep -v temporary | grep -v deprecated | grep -v 'scope link' | grep -v 'scope host' | awk '{print $2}' | awk -F '/' '{print $1}')
    
    if [ -n "$CURRENT_IPv6" ]; then
        echo "当前的公共 IPv6 地址为：$CURRENT_IPv6"
    else
        echo "未能获取当前的公共 IPv6 地址"
    fi

    if [ -n "$CURRENT_IPv6" ]; then
        # 获取上次记录的 IPv6 地址
        LAST_IPv6=$(cat ./last_ipv6.txt 2>/dev/null)

        # 检查 IPv6 是否发生变化
        if [ "$CURRENT_IPv6" != "$LAST_IPv6" ]; then
            # 更新 DNS 记录
            RESPONSE=$(curl -s "$API_URL?version=1&type=xml&key=$API_KEY&domain=$DOMAIN&rrid=$RRID&rrhost=$HOSTNAME&rrvalue=$CURRENT_IPv6")
            # 提取响应状态
            STATUS=$(echo "$RESPONSE" | grep -oP '(?<=<code>)[^<]+')

            # 检查更新是否成功
            if [ "$STATUS" == "300" ]; then
                # 将当前 IPv6 地址保存到文件
                echo "$CURRENT_IPv6" > ./last_ipv6.txt
                echo "$(date): DNS 记录已成功更新。新的 IPv6 地址为：$CURRENT_IPv6"
            else
                echo "$(date): 更新 DNS 记录失败。错误码：$STATUS"
            fi
        else
            echo "$(date): 未检测到 IPv6 变化。当前 IPv6 地址为：$CURRENT_IPv6"
        fi
    else
        echo "$(date): 未能获取当前 IPv6 地址"
    fi
}

# 持续更新 DNS 记录
while true; do
    update_dns_record
    sleep 600 # 等待 1 小时后再次更新
done
