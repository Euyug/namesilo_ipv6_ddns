**[English](README.md), [中文](README_zh.md).**
# Namesilo IPv6 ddns

Simple and Easy-to-Use IPv6 DDNS Script

## Prerequisites

Before using this script, ensure you have the following prerequisites installed:
- `curl` for making HTTP requests

## Configuration

Create a JSON configuration file named `config.json` with the following structure:

```json
{
  "API_KEY": "YOUR_API_KEY",
  "DOMAIN": "YOUR_DOMAIN",
  "HOSTNAME": "YOUR_HOSTNAME",
  "API_URL": "https://www.namesilo.com/api/dnsUpdateRecord",
  "NETWORK_INTERFACE": "YOUR_NETWORK_INTERFACE(which have ipv6 address)",
  "rrid_URL": "https://www.namesilo.com/api/dnsListRecords"
}
```

Make sure to replace placeholders with your actual values.

Get apikey：https://www.namesilo.com/account/api-manager
## Usage

```bash
bash -c "$(curl --insecure -fsSL https://raw.githubusercontent.com/Euyug/namesilo_ipv6_ddns/main/install_ddns.sh)"
```
1. Set execute permission for the script:

```bash
chmod +x ddns.sh
```

2. Run the script:

```bash
./ddns.sh
```

3.Create the startup link:
```bash
echo -e "[Unit]\nDescription=DDNS Service\nAfter=network.target\n\n[Service]\nType=simple\nExecStart=$(pwd)/ddns.sh\nWorkingDirectory=$(pwd)\nRestart=always\nUser=root\nGroup=root\n\n[Install]\nWantedBy=multi-user.target" | sudo tee /etc/systemd/system/ddns.service > /dev/null
```

4.Enable system startup:

```bash
sudo systemctl daemon-reload
sudo systemctl enable ddns.service
sudo systemctl start ddns.service
```


The script will continuously monitor the IPv6 address of the specified network interface and update the DNS record on Namesilo if any changes are detected.

## Notes

- The script fetches the current IPv6 address from the specified network interface and compares it with the last recorded IPv6 address. If a change is detected, it updates the DNS record using the Namesilo API.
- It sleeps for 1 hour between updates. You can adjust the sleep duration in the script according to your preference.

Please ensure that your Namesilo API key has the necessary permissions to update DNS records.
