# Asuswrt-shell-monitoring
ASUS TUF-BE3600 (stock firmware!) ssh shell access plugins, but probably compatible with all ASUSWRT based routers when they have ssh enabled.

This will showcase a short introduction in how much shell tools are available on the router on the stock firmware to get almost anything you need (monitoring,iptable scripts,...).

This is a feature always completely overlooked by any reviewer and might help linux minded people to chose their new router who is linux/busybox powered, and might integrate flawlessly in their linux projects.

Its basicly a big promotional piece (and thank you) to ASUS, trying to highlight its most treasured (and forgotten) feature: ssh with shell access directly to the router. They did a good job there leaving most tools exposed to the user, and basicly no one even seems to know.

Most of the script will be in the "nagios format", so actually also outputing performance stats. Please enjoy everything that is possible on the linux powered asus router.

# check_asusr_linkspeeds.sh [NagiosPlugin]
With the broadcom SoC, physical ports are not directly exposed. Due to the architecture of Broadcom-based consumer routers, physical Ethernet ports are typically not exposed as individual interfaces in the Linux networking stack. Instead, the switch ASIC (often integrated with the SoC) is abstracted behind a single aggregated interface.
WAN and LAN planes (as I understand it) are still visible, as are our radio emmiters.
This script monitors these available planes. as far as I understand it:

```
interface ==> what it is
wl0.1 ==> WLAN network 1 (2.4ghz)
w1.1 ==> WLAN network 2 (5ghz)
eth0 ==> main WAN plane
eth1 ==> main LAN plane
```
The "wl" devices might be the band or the "networks" you created in the GUI. For me, one network is only 2.4ghz and the other is only 5ghz.

# get_temperature.sh [NagiosPlugin]
A small script that will get the temperature of the broadcom SoC.
Some instances report the temp with a 10°C offset. I saw the offset change during an asusrouter firmware upgrade, thats the only reason I spotted this. So this may need adapting based on firmware.

# check_cpu_ssh_top.sh [NagiosPlugin]
Hacky script that uses ncurses top to extract the cpu usage we need. Not the most ideal approach, but every busybox/linux device on the planet for some reason has top. Let's leverage this.

# check_mem.sh [NagiosPlugin]
Small nagios script I found somewhere and needed little adaptation monitor system memory on ASUSWRT routers.

# check_disk.sh [NagiosPlugin]
small script leveraging df on most linux systems, also the asusrouter.

# blockinternetaccess.sh
Take control of your LAN and block ips who are not allowed to traverse the gateway (=no internet), using iptables on the router.
