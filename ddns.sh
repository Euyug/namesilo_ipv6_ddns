#!/bin/bash
# 读取配置文件
CONFIG_FILE="./config.json"
API_KEY=$(jq -r '.API_KEY' $CONFIG_FILE)
DOMAIN=$(jq -r '.DOMAIN' $CONFIG_FILE)
HOSTNAME=$(jq -r '.HOSTNAME' $CONFIG_FILE)
API_URL=$(jq -r '.API_URL' $CONFIG_FILE)
rrid_URL=$(jq -r '.rrid_URL' $CONFIG_FILE)
TARGET_VALUE="${HOSTNAME}.${DOMAIN}"
NETWORK_INTERFACE=$(jq -r '.NETWORK_INTERFACE' $CONFIG_FILE)






# 发送HTTP请求并解析XML响应
RRID=$(curl -s "${rrid_URL}?version=1&type=xml&key=${API_KEY}&domain=${DOMAIN}" | \
       xmlstarlet sel -t -m "//resource_record[host='${TARGET_VALUE}']" -v "record_id" -n)

# 打印rrid
if [ -n "$RRID" ]; then
    echo "RRID for ${TARGET_VALUE}: $RRID"
else
    echo "未找到RRID"
fi
#-----------------------------

# Function to update DNS record
update_dns_record() {
    # Get current public IPv6 address
    
#    CURRENT_IPv6=$(curl -s https://api6.ipify.org)
 CURRENT_IPv6=$(ip -6 addr show dev $NETWORK_INTERFACE | grep inet6 | grep -v temporary | grep -v deprecated | grep -v 'scope link' | grep -v 'scope host' | awk '{print $2}' | awk -F '/' '{print $1}')

if [ -n "$CURRENT_IPv6" ]; then
    echo "当前的公共 IPv6 地址为：$CURRENT_IPv6"
else
    echo "未能获取当前的公共 IPv6 地址"
fi

    if [ -n "$CURRENT_IPv6" ]; then
        # Get the last recorded IPv6 address
        LAST_IPv6=$(cat ./last_ipv6.txt 2>/dev/null)

        # Check if IPv6 has changed
        if [ "$CURRENT_IPv6" != "$LAST_IPv6" ]; then
            # Update the DNS record
#            RESPONSE=$(curl -s "$API_URL?version=1&type=xml&key=$API_KEY&domain=$DOMAIN&rrhost=$HOSTNAME&rrvalue=$CURRENT_IPv6")
            RESPONSE=$(curl -s "$API_URL?version=1&type=xml&key=$API_KEY&domain=$DOMAIN&rrid=$RRID&rrhost=$HOSTNAME&rrvalue=$CURRENT_IPv6&rrttl=$RRTTL")
            # Extract the response status
            STATUS=$(echo "$RESPONSE" | grep -oP '(?<=<code>)[^<]+')

            # Check if the update was successful
            if [ "$STATUS" == "300" ]; then
                # Save current IPv6 to file
                echo "$CURRENT_IPv6" > ./last_ipv6.txt
                echo "$(date): DNS record updated successfully. New IPv6: $CURRENT_IPv6"
            else
                echo "$(date): Failed to update DNS record. Error code: $STATUS"
            fi
        else
            echo "$(date): No IPv6 change detected. Current IPv6: $CURRENT_IPv6"
        fi
    else
        echo "$(date): Failed to get current IPv6 address"
    fi
}

# Loop to continuously update DNS record
while true; do
    update_dns_record
    sleep 3600 # Sleep for 1 hour before next update
done
