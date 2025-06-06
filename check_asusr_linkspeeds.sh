#!/bin/sh

#wl0.1 ==> WLAN network 1 (2.4ghz)
#w1.1 ==> WLAN network 2 (5ghz)
#eth0 ==> main WAN plane
#eth1 ==> main LAN plane

echo > /tmp/asuslinkspeed

function calculate_iface {
export name=$1
fname=$(echo $name|sed 's/\./_/g')
#input
output_start=$(sudo ssh -p 11123 eggz@asusr "ifconfig $1")
sleep 60
output_end=$(sudo ssh -p 11123 eggz@asusr "ifconfig $1")

#calculate
iface_rxb_start=$(echo "$output_start"|grep -Eo 'RX bytes:'.*'\) '|cut -d ':' -f2|awk '{print $1}' 2>/dev/null)
iface_rxb_end=$(echo "$output_end"|grep -Eo 'RX bytes:'.*'\) '|cut -d ':' -f2|awk '{print $1}' 2>/dev/null)

iface_txb_start=$(echo "$output_start"|grep -Eo 'TX bytes:'.*|cut -d ':' -f2|awk '{print $1}' 2>/dev/null)
iface_txb_end=$(echo "$output_end"|grep -Eo 'TX bytes:'.*|cut -d ':' -f2|awk '{print $1}' 2>/dev/null)

iface_rxb_delta=$(( $iface_rxb_end - $iface_rxb_start ))
iface_txb_delta=$(( $iface_txb_end - $iface_txb_start ))

iface_rxkb_delta=$(echo "( $iface_rxb_delta / 60 ) / 1024" | bc)
iface_txkb_delta=$(echo "( $iface_txb_delta / 60 ) / 1024" | bc)

echo "Interface $1 ($2) Received: $iface_rxkb_delta kB/s"
echo "Interface $1 ($2) Transmit: $iface_txkb_delta kB/s"
echo "${fname}rxkbs=$iface_rxkb_delta " >> /tmp/asuslinkspeed
echo "${fname}txkbs=$iface_txkb_delta " >> /tmp/asuslinkspeed
}

calculate_iface "wl0.1" "WLAN 2.4Ghz IoT" &
calculate_iface "wl1.1" "WLAN 5Ghz Main " &
calculate_iface "eth0" "WLAN plane" &
calculate_iface "eth1" "LAN plane" &

sleep 62

echo "| $(cat /tmp/asuslinkspeed|xargs) ;;;"
