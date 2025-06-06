#!/bin/bash
if [ "$1" == "" ] || [ "$1" == "--h" ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
        echo "Please give the LAN IP you want to isolate from the internet."
        exit
fi

#First check if its already blocked to avoid double entries in the chain
iplistfull=$(sudo ssh -n -p 11123 eggz@asusr "/usr/sbin/iptables -L -n")
iplist=$(echo "$iplistfull" | grep 'DROP')

if [[ $iplist = *'DROP'*"$1"* ]]; then
        echo "$1 seems to be already blocked."
else
        echo "$1 is not blocked. Taking action. [blockscript internal]"
        ssh -n -p 11123 eggz@asusr "/usr/sbin/iptables -I FORWARD -s $1 -j DROP"
        if [ "$(grep -Fw $1 /usr/lib64/monitoring-plugins/lanwanguardian/inetlist)" == "" ]; then #ip is not in the list
                echo "first-time adding ip to inet blocklist [blockscript internal]"
                echo "$1" >> /usr/lib64/monitoring-plugins/lanwanguardian/inetlist
        else
                echo "inet ip was already permabanned. [blockscript internal]"
        fi
fi
