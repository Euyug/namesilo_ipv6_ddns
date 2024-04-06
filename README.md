# Automatic DNS Update Script

This Bash script `ddns.sh` is designed to automatically update DNS records on Namesilo based on the IPv6 address of a specified network interface.

## Prerequisites

Before using this script, ensure you have the following prerequisites installed:

- `jq` for parsing JSON
- `xmlstarlet` for parsing XML
- `curl` for making HTTP requests

## Configuration

Create a JSON configuration file named `config.json` with the following structure:

```json
{
  "API_KEY": "YOUR_API_KEY",
  "DOMAIN": "YOUR_DOMAIN",
  "HOSTNAME": "YOUR_HOSTNAME",
  "API_URL": "https://www.namesilo.com/api/dnsUpdateRecord",
  "NETWORK_INTERFACE": "YOUR_NETWORK_INTERFACE",
  "rrid_URL": "https://www.namesilo.com/api/dnsListRecords"
}
```

Make sure to replace placeholders with your actual values.

## Usage

1. Set execute permission for the script:

```bash
chmod +x ddns.sh
```

2. Run the script:

```bash
./ddns.sh
```

The script will continuously monitor the IPv6 address of the specified network interface and update the DNS record on Namesilo if any changes are detected.

## Notes

- The script fetches the current IPv6 address from the specified network interface and compares it with the last recorded IPv6 address. If a change is detected, it updates the DNS record using the Namesilo API.
- It sleeps for 1 hour between updates. You can adjust the sleep duration in the script according to your preference.

Please ensure that your Namesilo API key has the necessary permissions to update DNS records.
