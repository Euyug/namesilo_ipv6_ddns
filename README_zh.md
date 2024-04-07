**其他语言版本: [English](README.md), [中文](README_zh.md).**
### Namesilo IPv6 ddns

这个 Bash 脚本 `ddns.sh` 旨在基于指定网络接口的 IPv6 地址自动更新 Namesilo 上的 DNS 记录。

#### 需要安装

在使用此脚本之前，请确保已安装：

- `jq` 用于解析 JSON
- `xmlstarlet` 用于解析 XML
- `curl` 用于进行 HTTP 请求

#### 配置

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
```bash
chmod +x ddns.sh
```
