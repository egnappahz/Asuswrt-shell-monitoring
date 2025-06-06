#!/bin/bash
warn=66
crit=70
us=
exitc=0
msg=

while getopts ":h:p:u:" OPTION
do
        case $OPTION in
        h)
        host=$OPTARG
        ;;
        p)
        port=$OPTARG
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

warn=66
crit=70

ssh -p $port -n -o ConnectTimeout=2 $user@$host 2> /dev/null
if [ "$?" == "255" ]; then
	echo "DEPENDANT: ssh timed out or is not working. "
	exit 3
fi
tempVAL=$(ssh -p $port -n "$user@"$host "echo \$(cat /sys/class/thermal/thermal_zone0/temp)")
templong=$(echo "$tempVAL / 1000" | bc -l | sed 's/^00*\|00*$//g')

temp=$(echo $templong | cut -d '.' -f1)

#since 382.1_0, a wrong offset of +10° was used?
temp=$(($temp - 10))
templong=$(echo "$templong - 10" | bc)

if [[ $temp -ge $warn ]]; then
	exitc=1
	msg="WARNING: TEMP is $temp °C | temp=$templong;;;;"
fi
if [[ $temp -ge $crit ]]; then
	exitc=2
	msg="CRITICAL: TEMP is $temp °C !! | temp=$templong;;;;"

fi

if [ -z "$msg" ]; then {
msg="OK: TEMP is $temp | temp=$templong;;;;"
}
fi
echo $msg
exit $exitc
