#!/bin/bash

cat >> 'EOF'

 __      ______  ______  ______  ______  __   __  ______  ______  __  __    
/\ \    /\  __ \/\  ___\/\  ___\/\  ___\/\ "-.\ \/\__  _\/\  == \/\ \_\ \   
\ \ \___\ \ \/\ \ \ \__ \ \___  \ \  __\\ \ \-.  \/_/\ \/\ \  __<\ \____ \  
 \ \_____\ \_____\ \_____\/\_____\ \_____\ \_\\"\_\ \ \_\ \ \_\ \_\/\_____\ 
  \/_____/\/_____/\/_____/\/_____/\/_____/\/_/ \/_/  \/_/  \/_/ /_/\/_____/ 


                        A file integrity monitoring tool

EOF
CONFIG="./config.ini"
source "$CONFIG"

declare -A ATTEMPTS

tail -F "$LOG_FILE" | while read -r line; do
    if [[ "$line" =~ "Failed password for" ]]; then
        IP=$(echo "$line" | grep -oP 'from \K\S++')
        TIMESTAMP=$(date +%s)

        if [[ -n "$IP" ]]; then
            ATTEMPTS["$IP,$TIMESTAMP"]=1

            # Count attempts in the last $TIMEFRAME seconds
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
            fi
        fi
    fi
done
