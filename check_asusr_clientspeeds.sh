#!/bin/bash

ROUTER_IP="asusr"
SSH_USER="eggz"
PORT="11123"
STATE_FILE="/tmp/asusclientspeeds"

# 1. Run Step1 script on router (idempotent)
sudo ssh -p $PORT "$SSH_USER@$ROUTER_IP" 'bash -s' < asusr_clientspeeds_init.sh >/dev/null

# 2. Fetch iptables counters from router (bytes src_ip dst_ip)
current_data=$(ssh -p $PORT "$SSH_USER@$ROUTER_IP" 'iptables -L bwmon -v -n -x | tail -n +3' | awk '{print $2, $8, $9}')
# 3. Load previous counters (source and dest combined)
declare -A prev_bytes_src
declare -A prev_bytes_dst
if [[ -f "$STATE_FILE" ]]; then
  while read -r direction ip bytes; do
    if [[ "$direction" == "SRC" ]]; then
      prev_bytes_src["$ip"]=$bytes
    elif [[ "$direction" == "DST" ]]; then
      prev_bytes_dst["$ip"]=$bytes
    fi
  done < "$STATE_FILE"
fi

# 4. Aggregate current bytes per IP and direction
declare -A curr_bytes_src
declare -A curr_bytes_dst
while read -r bytes src_ip dst_ip; do
  [[ -z "$bytes" || -z "$src_ip" || -z "$dst_ip" ]] && continue
  curr_bytes_src["$src_ip"]=$(( ${curr_bytes_src["$src_ip"]:-0} + bytes ))
  curr_bytes_dst["$dst_ip"]=$(( ${curr_bytes_dst["$dst_ip"]:-0} + bytes ))
done <<< "$current_data"

# 5. Calculate delta, convert to kB/s and print in a table

# Create temp state file
echo "" > "$STATE_FILE.tmp"

printf "%-15s %-9s %s\n" "IP" "Direction" "Speed (kB/s)"

# Combine unique IPs from both src and dst
declare -A all_ips
for ip in "${!curr_bytes_src[@]}"; do
  all_ips["$ip"]=1
done
for ip in "${!curr_bytes_dst[@]}"; do
  all_ips["$ip"]=1
done

perf_output="| "
for ip in "${!all_ips[@]}"; do
  name=$(grep -F $ip /etc/hosts|tail -n1|awk '{print $2}')
  if [ "$ip" == '0.0.0.0/0' ]; then #We dont care about totals. Not the point of this script.
    continue
  fi
  # SRC direction (upload)
  curr=${curr_bytes_src[$ip]:-0}
  prev=${prev_bytes_src[$ip]:-0}
  delta=$((curr - prev))
  (( delta < 0 )) && delta=0
  kbps_src=$(awk "BEGIN { printf \"%.1f\", $delta / 1024 / 60 }")
  echo "SRC $ip $curr" >> "$STATE_FILE.tmp"
  printf "%-15s %-9s %7s\n" "$name" "SRC" "$kbps_src"
  perf_output="$perf_output ${name}_up=$(echo "$delta /1024 / 60"|bc)"

  # DST direction (download)
  curr=${curr_bytes_dst[$ip]:-0}
  prev=${prev_bytes_dst[$ip]:-0}
  delta=$((curr - prev))
  (( delta < 0 )) && delta=0
  kbps_dst=$(awk "BEGIN { printf \"%.1f\", $delta / 1024 / 60 }")
  echo "DST $ip $curr" >> "$STATE_FILE.tmp"
  printf "%-15s %-9s %7s\n" "$name" "DST" "$kbps_dst"
  perf_output="$perf_output ${name}_down=$(echo "$delta /1024 / 60"|bc)"
done
perf_output="$perf_output ;;;"
echo "$perf_output"
# Replace old state file
mv "$STATE_FILE.tmp" "$STATE_FILE"
