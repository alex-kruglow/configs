#!/bin/bash
### BEGIN INIT INFO
# Provides:          iptables
# Required-Start:    $network $local_fs
# Required-Stop:     $network $local_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Iptables firewall rules.
# Description:       It sets iptables firewall rules to block all connections except SSH service (22 port).
### END INIT INFO

ipt=/sbin/iptables
TCP_PORTS="22,443"
#UDP_PORTS="1900"

start()
{
	echo 'Start iptables';
        $ipt -F;
        $ipt -X;
        echo 1 > /proc/sys/net/ipv4/ip_forward;
        # Create NAT
        # $ipt -t nat -A POSTROUTING -o eth0 -j MASQUERADE;
        # Accept created connections
        $ipt -t filter -I INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT;
        # Accept localhost
        $ipt -t filter -I INPUT -s 127.0.0.1 -j ACCEPT;
        # Accept needd ports
        $ipt -t filter -I INPUT -p tcp -m multiport --destination-port $TCP_PORTS -j ACCEPT;
        # $ipt -t filter -I INPUT -p udp -m multiport --destination-port $UDP_PORTS -j ACCEPT;
        # Allow ping
        $ipt -t filter -I INPUT -p icmp -j ACCEPT;
	# minidlna
	$ipt -t filter -I INPUT -p igmp -d 192.168.1.0/24 -j ACCEPT;
	$ipt -t filter -I INPUT -p tcp --dport 8200 -j ACCEPT;
	$ipt -t filter -I INPUT -p udp -d 239.255.255.250/32 --dport 1900 -j ACCEPT;
	# end of minidlna

        # Set default policies
        $ipt -P INPUT DROP;
        $ipt -P OUTPUT ACCEPT;
        $ipt -P FORWARD DROP;
}
stop()
{
	echo 'Stop iptables';
        $ipt -F;
        $ipt -X;
        $ipt -P INPUT ACCEPT;
        $ipt -P OUTPUT ACCEPT;
        $ipt -P FORWARD ACCEPT;
}

case "$1" in
        start) start
                ;;
        stop) stop
                ;;
        restart) stop
                start
                ;;
esac
exit 0;

