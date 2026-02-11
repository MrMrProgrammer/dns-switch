# dns-switch.sh

A simple Bash script to quickly switch your DNS settings on Linux using `nmcli` (NetworkManager CLI).  

With this script, you can select from a list of predefined DNS providers or reset to the default DNS.

---

## Features

- Detects the currently active network connection.
- Shows the active DNS provider or custom DNS addresses.
- Supports a variety of DNS providers (Google, Cloudflare, OpenDNS, etc.).
- Option to reset DNS to automatic (DHCP) settings.
- Simple interactive menu for choosing DNS.

---

## Prerequisites

- Linux with [NetworkManager](https://wiki.gnome.org/Projects/NetworkManager) installed.
- `nmcli` must be available in your system path.

Check with:

```bash
command -v nmcli
```

---

## Installation

1. Clone this repository:

```bash
git clone https://github.com/MrMrProgrammer/dns-switch.git
cd dns-switch
```

2. Make the script executable:

```bash
chmod +x dns-switch.sh
```

---

## Usage

Run the script:

```bash
./dns-switch.sh
```

You will see something like:

```
🌐 Active connection: wlp2s0
🔎 Active DNS: Automatic (DHCP)

Select DNS:
 1) Mokhaberat
 2) ShecanPro
 3) Shecan
 4) Electro
 5) Google
 ...
17) Reset

Enter number:
```

- Enter the number corresponding to the DNS provider you want.
- The script will apply the selected DNS immediately.

---

## DNS Providers Included

- Mokhaberat
- ShecanPro
- Shecan
- Electro
- Google
- RadarGame
- 403.online
- Shelter
- Begzar
- Pishgaman
- Shatel
- Cisco
- OpenDNS
- Verisign
- Cloudflare
- Yandex

---

## Versioning

- **v1.0.0**: Initial release
- **v2.0.0**: Updated DNS list / improvements

---

## License

MIT License. Feel free to use, modify, and redistribute.
