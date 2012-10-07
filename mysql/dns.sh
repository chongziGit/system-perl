#!/bin/bash
source ./conf.sh
action=$1
domain=$2
ip=$3
dns_conf='/var/named/chroot/etc/named.conf'
dns_parse_conf="/var/named/chroot/var/named/named.${dns_domain}"
dns_ip_parse_conf="/var/named/chroot/var/named/${dns_domain}.local"
ip_to_domain=`echo  $network | perl -e 'chomp($_=(<>));@str=split ("|",$_);print  @str,"\n"'`
function dns_init {
	yum -y install bind bind-utils bind-chroot
}
function dns_create {
cat > $dns_conf <<EOF
options
{
	directory "/var/named";
	listen-on port 53 { $dns_server; };
	forwarders{ 8.8.8.8; };
	allow-query{ any; };
};


zone "$dns_domain"  IN
{
	type master;
	file "named.$dns_domain";
        allow-update { none; };
};

zone "${ip_to_domain}.in-addr.arpa" IN {
	type master;
        file "${dns_domain}.local";
        allow-update { none; };
};

include "/etc/rndc.key";
EOF

cat > $dns_parse_conf <<EOF
\$TTL 86400

@ IN SOA $dns_domain. root.$dns_domain. (

		1997022700 ; Serial

		28800 ; Refresh

		14400 ; Retry

		3600000 ; Expire

		86400 ) ; Minimum  
	 IN NS ${dns_domain}.
puppet	 IN A	$puppet_server
EOF
cat > $dns_ip_parse_conf <<EOF
\$TTL 86400

@ IN SOA $dns_domain. root.$dns_domain. (

		1997022700 ; Serial

		28800 ; Refresh

		14400 ; Retry

		3600000 ; Expire

		86400 ) ; Minimum  
	 IN NS ${dns_domain}.
108	 IN PTR	 puppet.${dns_domain}.
EOF
}

function dns_add {
	add_domain=$1
	add_ip="${network}.$add_domain"
	grep "$add_domain.*IN.*A" $dns_parse_conf &> /dev/null
	if [ $? -ne 0 ];then
		echo "$add_domain	IN A 	$add_ip" >> $dns_parse_conf
		echo "$add_domain	IN PTR 	${add_domain}.${dns_domain}." >> $dns_ip_parse_conf	
		service named reload
	fi
}
function dns_delete {
	delete_domain=$1
	sed -i "/$delete_domain/" $dns_parse_conf
	sed -i "/$delete_domain/" $dns_ip_parse_conf
	service named reload
		
}
function dns_start {
        /etc/init.d/named status > /dev/null
        if [ $? -eq 0 ] ;then
                /etc/init.d/named reload
        else
                /etc/init.d/named
		iptables -A INPUT -p tcp --dport 53 -j ACCEPT
		iptables -A OUTPUT -p tcp --sport 53 -j ACCEPT
		iptables -A INPUT -p udp --dport 53 -j ACCEPT
		iptables -A OUTPUT -p udp --sport 53 -j ACCEPT
        fi

}

case $action in
add)
	dns_add $domain $ip
	;;	
*)
	dns_init
	dns_create
	dns_start
	;;
esac
