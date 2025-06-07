#!/bin/bash

# Disable Broadcom fastcache if needed (your original lines)
fc disable
fc flush

# Create and flush bwmon chain if it exists; otherwise, create it
iptables -N bwmon 2>/dev/null

# Remove all jumps to bwmon from FORWARD chain before inserting
while iptables -D FORWARD -j bwmon 2>/dev/null; do :; done
iptables -I FORWARD -j bwmon

# Get current IPs from neighbors on br0 (IPv4 only)
current_ips=$(ip neigh show dev br0 | awk '/lladdr/ {print $1}' | sort -u)

# Gather existing rules in bwmon, format: "source IP" and "destination IP"
# We'll parse rules that look like "-s IP" or "-d IP" followed by RETURN
existing_src_ips=$(iptables -L bwmon -n --line-numbers | awk '{print $5}'|grep -v '0.0.0.0/0' | sort -u)
existing_dst_ips=$(iptables -L bwmon -n --line-numbers | awk '{print $6}'|grep -v '0.0.0.0/0' | sort -u)


# Add missing IP rules for both source and destination
for ip in $current_ips; do
  if [ "$(echo "$existing_src_ips"|grep -F $ip)" == "" ]; then
    iptables -A bwmon -s "$ip" -j RETURN
  fi
  if [ "$(echo "$existing_dst_ips"|grep -F $ip)" == "" ]; then
    iptables -A bwmon -d "$ip" -j RETURN
  fi
done

# Remove rules for source IPs no longer present
for ip in $existing_src_ips; do
  if [ "$(echo "$current_ips"|grep -F $ip)" == "" ]; then
    # Delete all rules matching -s IP RETURN in bwmon
    while rule_num=$(iptables -L bwmon -n --line-numbers | grep "RETURN" | grep "\-s $ip" | awk '{print $1}' | head -n1); do
      [ -z "$rule_num" ] && break
      iptables -D bwmon "$rule_num"
    done
  fi
done

# Remove rules for destination IPs no longer present
for ip in $existing_dst_ips; do
  if [ "$(echo "$current_ips"|grep -F $ip)" == "" ]; then
    # Delete all rules matching -d IP RETURN in bwmon
    while rule_num=$(iptables -L bwmon -n --line-numbers | grep "RETURN" | grep "\-d $ip" | awk '{print $1}' | head -n1); do
      [ -z "$rule_num" ] && break
      iptables -D bwmon "$rule_num"
    done
  fi
done
