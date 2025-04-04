#!/bin/bash

CONFIG="./config.ini"
source "$CONFIG"

declare -A ATTEMPTS

echo "[*] LogSentry started. Watching: $LOG_FILE"

tail -F "$LOG_FILE" | while read -r line; do
    if [[ "$line" =~ "Failed password for" ]]; then
        IP=$(echo "$line" | grep -oP 'from \K[\d\.]+')
        TIMESTAMP=$(date +%s)

        if [[ -n "$IP" ]]; then
            ATTEMPTS["$IP,$TIMESTAMP"]=1

            COUNT=0
            NOW=$(date +%s)
            for key in "${!ATTEMPTS[@]}"; do
                IFS=',' read -r stored_ip stored_time <<< "$key"
                if [[ "$stored_ip" == "$IP" && $((NOW - stored_time)) -le $TIMEFRAME ]]; then
                    ((COUNT++))
                fi
            done

            if (( COUNT >= THRESHOLD )); then
                echo "[!] Alert: $IP exceeded threshold ($COUNT attempts)"
                ./notify.sh "$IP" "$COUNT"
                if [ "$BLOCK_IP" = true ]; then
                    sudo ufw deny from "$IP"
                    echo "[+] IP $IP blocked using ufw"
                fi
                sleep 2  # prevent spam on same detection loop
            fi
        fi
    fi
done
