#!/bin/bash

while getopts ":h:c:w:p:u:P:" OPTION
do
        case $OPTION in
        h)
        host=$OPTARG
        ;;
        w)
        warn=$OPTARG
        ;;
        c)
        crit=$OPTARG
        ;;
        p)
        port=$OPTARG
        ;;
        P)
        path=$OPTARG
        ;;
        u)
        user=$OPTARG
        ;;
        esac
done

if [ "$port" == "" ]; then
port=22
fi

if [ "$user" == "" ]; then
user=root
fi

ssh -p $port -o ConnectTimeout=2 $user@$host "exit" > /dev/null
if [ "$?" == "255" ]; then
	echo "DEPENDANT: ssh timed out or is not working. "
	exit 3
fi

info=$(ssh -p $port $user@$host  "df -h | grep -w $path;df | grep -w $path")
used=$(echo $info | awk '{print $3}')
usedkb=$( echo "$info" | awk 'FNR==2{print $3}' )
usedperc=$(echo $info | awk '{print $5}')
freeperc=$(echo "100 - $usedperc" | tr -d "%" | bc)

if [[ $crit -ge $freeperc ]]; then
echo "CRITICAL: for volume $path":"$used is used and $freeperc"%" is free. | frp=$freeperc;;;; us=$usedkb;;;;"
exit 2
elif [[ $warn -ge $freeperc ]]; then
echo "WARNING: for volume $path":"$used is used and $freeperc"%" is free. | frp=$freeperc;;;; us=$usedkb;;;;"
exit 1
else
echo "OK: for volume $path":" $used is used and $freeperc"%" is free. | frp=$freeperc;;;; us=$usedkb;;;;"
exit
fi
