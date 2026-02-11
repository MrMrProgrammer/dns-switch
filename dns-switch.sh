#!/usr/bin/env bash
set -euo pipefail

clear

# === Helpers ===
error() {
    echo "❌ $1"
    exit 1
}

restart_connection() {
    nmcli connection down "$1" >/dev/null 2>&1
    nmcli connection up "$1"   >/dev/null 2>&1
}

normalize_dns() {
    echo "$1" | tr ',' ' ' | xargs | tr -s ' '
}

# === Checks ===
command -v nmcli >/dev/null 2>&1 || \
    error "nmcli not found. Please install NetworkManager."

# === Get active connection ===
CONNECTION_NAME=$(nmcli -t -f NAME,DEVICE,STATE connection show --active \
    | awk -F: '$2 != "lo" && $2 !~ /docker|br-/ && $3 == "activated" {print $1; exit}')

[[ -z "$CONNECTION_NAME" ]] && error "No active internet connection found."

echo "🌐 Active connection: $CONNECTION_NAME"

# === DNS List ===
declare -A DNS_SERVERS=(
    [Mokhaberat]="217.218.127.127 217.218.155.155"
    [ShecanPro]="178.22.122.101 185.51.200.1"
    [Shecan]="185.51.200.2 178.22.122.100"
    [Electro]="78.157.42.100 78.157.42.101"
    [Google]="8.8.8.8 8.8.4.4"
    [RadarGame]="10.202.10.10 10.202.10.11"
    [403.online]="10.202.10.202 10.202.10.102"
    [Shelter]="94.232.174.194 94.232.174.194"
    [Begzar]="185.55.226.26 185.55.225.25 185.55.224.24"
    [Pishgaman]="5.202.100.100 5.202.100.101"
    [Shatel]="85.15.1.14 85.15.1.15"
    [Cisco]="208.67.222.222 208.67.220.220"
    [OpenDNS]="208.67.222.222 208.67.220.220"
    [Verisign]="64.6.64.6 64.6.65.6"
    [Cloudflare]="1.1.1.1 1.0.0.1"
    [Yandex]="77.88.8.8 77.88.8.1"
)

# === Show current DNS ===
CURRENT_DNS=$(nmcli -g ipv4.dns connection show "$CONNECTION_NAME")

if [[ -z "$CURRENT_DNS" ]]; then
    echo "🔎 Active DNS: Automatic (DHCP)"
else
    CURRENT_NORMALIZED=$(normalize_dns "$CURRENT_DNS")
    MATCH_FOUND=false

    for name in "${!DNS_SERVERS[@]}"; do
        if [[ "$CURRENT_NORMALIZED" == "$(normalize_dns "${DNS_SERVERS[$name]}")" ]]; then
            echo "🔎 Active DNS: $name"
            MATCH_FOUND=true
            break
        fi
    done

    [[ "$MATCH_FOUND" == false ]] && \
        echo "🔎 Active DNS: $CURRENT_NORMALIZED"
fi

# === Menu ===
echo ""
echo "Select DNS:"
options=("${!DNS_SERVERS[@]}" "Reset")

for i in "${!options[@]}"; do
    printf "%2d) %s\n" $((i+1)) "${options[$i]}"
done

echo ""
read -p "Enter number: " choice_num

if ! [[ "$choice_num" =~ ^[0-9]+$ ]] || (( choice_num < 1 || choice_num > ${#options[@]} )); then
    error "Invalid choice."
fi

choice="${options[$((choice_num-1))]}"

echo ""
echo "⚡ Applying DNS settings for '$choice'..."

if [[ "$choice" == "Reset" ]]; then
    nmcli connection modify "$CONNECTION_NAME" ipv4.ignore-auto-dns no
    nmcli connection modify "$CONNECTION_NAME" ipv4.dns ""
    restart_connection "$CONNECTION_NAME"
    echo "🔥 DNS reset to default."
else
    nmcli connection modify "$CONNECTION_NAME" ipv4.ignore-auto-dns yes
    nmcli connection modify "$CONNECTION_NAME" ipv4.dns "${DNS_SERVERS[$choice]}"
    restart_connection "$CONNECTION_NAME"
    echo "🔥 DNS set to $choice"
fi

echo ""
