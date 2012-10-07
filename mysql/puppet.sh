#!/bin/bash
source ./conf.sh
source ./yum.sh

action=$1

function puppet_isset {
	status=` ps aux | grep puppet | grep -v 'grep' | grep puppetmasterd | wc -l`
	return $status
}
function puppet_init {
	rpm -Uhv http://apt.sw.be/redhat/el5/en/i386/rpmforge/RPMS/rpmforge-release-0.3.6-1.el5.rf.i386.rpm
	yum_download 'puppet'
	yum_download 'puppet-server'	
	yum -y install puppet puppet-server
}

function puppet_start {
	/usr/sbin/puppetmasterd
	if [ $? -eq 0 ];then
		echo 'puppet master start success'
	fi	
}
function puppet_add {
	domain=$1
	puppet_isset
	if [ $? -gt 0 ];then
		puppetca -s $domain
	else 
		puppet_init
		puppet_start
		puppetca -s  $domain
	fi
}
function puppet_create {
	puppet_init
	puppet_start
}

case $action in
add)
	puppet_add $2
	;;
*)
	puppet_create
	;;
esac
