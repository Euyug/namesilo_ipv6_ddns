**[English](README.md), [中文](README_zh.md).**
# Namesilo IPv6 ddns

几乎全部使用系统调用的ddns脚本

## 需要安装

在使用此脚本之前，请确保已安装：

- `curl` 用于进行 HTTP 请求

## 配置

创建一个名为 `config.json` 的 JSON 配置文件，具有以下结构：

```json
{
  "API_KEY": "YOUR_API_KEY",
  "DOMAIN": "YOUR_DOMAIN",
  "HOSTNAME": "YOUR_HOSTNAME",
  "API_URL": "https://www.namesilo.com/api/dnsUpdateRecord",
  "NETWORK_INTERFACE": "YOUR_NETWORK_INTERFACE(具有 IPv6 地址的接口)",
  "rrid_URL": "https://www.namesilo.com/api/dnsListRecords"
}
```
## 使用
1.为脚本设置执行权限：
```bash
chmod +x ddns.sh
```
2.运行：
```bash
./ddns.sh
```

3.创建自启链接:
```bash
echo -e "[Unit]\nDescription=DDNS Service\nAfter=network.target\n\n[Service]\nType=simple\nExecStart=$(pwd)/ddns.sh\nWorkingDirectory=$(pwd)\nRestart=always\nUser=root\nGroup=root\n\n[Install]\nWantedBy=multi-user.target" | sudo tee /etc/systemd/system/ddns.service > /dev/null
```

4.开启系统自启:

```bash
sudo systemctl daemon-reload
sudo systemctl enable ddns.service
sudo systemctl start ddns.service
```

### 注意事项
- 脚本从指定网络接口获取当前 IPv6 地址，并将其与上次记录的 IPv6 地址进行比较。如果检测到更改，则使用 Namesilo API 更新 DNS 记录。
- 它在更新之间休眠 1 小时。您可以根据需要在脚本中调整睡眠持续时间。

请确保你的 Namesilo API 密钥具有更新 DNS 记录所需的权限。
