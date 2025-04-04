#!/bin/bash

IP="$1"
COUNT="$2"
EMAIL=$(grep ALERT_EMAIL config.ini | cut -d '=' -f2 | tr -d '"')

SUBJECT="🚨 LogSentry Alert: $IP"
BODY="Detected $COUNT failed login attempts from $IP in the last timeframe."

echo "$BODY" | mail -s "$SUBJECT" "$EMAIL"

echo "[LogSentry] Alert sent for $IP ($COUNT attempts)" >> logsentry.log
