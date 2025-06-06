#!/bin/bash
warn=
crit=
us=
exitc=0
msg=

while getopts ":h:c:w:p:u:" OPTION
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

ssh -n -p $port -o ConnectTimeout=2 $user@$host 2> /dev/null

if [ "$?" == "255" ]; then
	echo "DEPENDANT: ssh timed out or is not working. "
	exit 3
fi
us="$(ssh -p $port $user@$host top -bn3 | grep -e "Cpu(s)" -e "CPU:" | awk 'FNR == 3 {print $2}')"
us="$(echo ${us//%})"

if [[ $(printf "%.0f\n" $us) -ge $warn ]]; then
	exitc=1
	msg="CPU WARNING: CPU usage (top) is $us% | usage=$us;;;;"
fi
if [[ $(printf "%.0f\n" $us) -ge $crit ]]; then
	exitc=2
	msg="CPU CRITICAL: CPU usage (top) is $us% | usage=$us;;;;"
fi

if [ -z "$msg" ]; then
	msg="CPU OK: CPU usage (top) is $us% | usage=$us;;;;"
fi

echo $msg
exit $exitc
