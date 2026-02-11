#!/bin/bash

# Check for nmcli
if ! command -v nmcli &> /dev/null; then
  echo "❌ دستور nmcli پیدا نشد. لطفاً NetworkManager را نصب کنید."
  exit 1
fi

# پیدا کردن کانکشن فعال که به اینترنت وصله (غیرداخلی و غیراز docker/bridge/lo)
CONNECTION_NAME=$(nmcli -t -f NAME,DEVICE,STATE connection show --active \
  | grep -v ":lo:" | grep -v docker | grep -v br- \
  | grep ":activated" \
  | head -n1 | cut -d: -f1)

if [[ -z "$CONNECTION_NAME" ]]; then
  echo "❌ اتصال فعال اینترنت پیدا نشد."
  exit 1
fi

echo "🔍 اتصال فعال شناسایی شد: $CONNECTION_NAME"

# DNS providers
declare -A dns_servers=(
  [shecan]="185.51.200.2 178.22.122.100"
  [electro]="78.157.42.100 78.157.42.101"
  [begzar]="185.55.226.26 185.55.225.25 185.55.224.24"
  [is]="192.168.10.1"
)

echo ""
echo "📡 انتخاب DNS:"
select choice in "${!dns_servers[@]}" "reset-to-default"; do
  if [[ "$choice" == "reset-to-default" ]]; then
    echo "🔄 بازنشانی DNS به حالت خودکار..."
    nmcli connection modify "$CONNECTION_NAME" ipv4.ignore-auto-dns no
    nmcli connection modify "$CONNECTION_NAME" ipv4.dns ""
    nmcli connection down "$CONNECTION_NAME" && nmcli connection up "$CONNECTION_NAME"
    echo "✅ DNS به حالت پیش‌فرض برگشت."
    break
  elif [[ -n "${dns_servers[$choice]}" ]]; then
    echo "🔧 در حال تنظیم DNS برای اتصال $CONNECTION_NAME به $choice..."
    nmcli connection modify "$CONNECTION_NAME" ipv4.ignore-auto-dns yes
    nmcli connection modify "$CONNECTION_NAME" ipv4.dns "${dns_servers[$choice]}"
    nmcli connection down "$CONNECTION_NAME" && nmcli connection up "$CONNECTION_NAME"
    echo "✅ DNS تغییر کرد به $choice (${dns_servers[$choice]})"
    break
  else
    echo "❌ انتخاب نامعتبر. مجدد تلاش کنید."
  fi
done

