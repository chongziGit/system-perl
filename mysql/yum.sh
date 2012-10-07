#!/bin/bash
source ./conf.sh
yum_repo_file='/etc/yum.repos.d/server.repo'
yum_http_server_root='/var/www/html'
yum_dir="${yum_http_server_root}/yum/server/"
yum_soft_list_dir="${yum_dir}/repodata/"
yum_soft_list_file="${yum_dir}/repodata/repomd.xml"

function yum_isset {
	[ -d $yum_dir ] || return 1
	[ -e $yum_soft_list_file ] || return 1
	return 0
}
function yum_init {
	yum -y install createrepo
	yum -y install yum-downloadonly
	[ -d "$yum_dir" ] || mkdir -p $yum_dir
	[ -d "$yum_soft_list_dir" ] || mkdir -p $yum_soft_list_dir
}
function yum_create {
	yum_isset || yum_init
	createrepo  $yum_dir
}
function yum_update {
	yum_isset || yum_init
	createrepo --update $yum_dir
}
function yum_server {
	yum -y install httpd	
	/etc/init.d/httpd start	
}
function yum_repo {
	cat > $yum_repo_file <<EOF
[server]

name=Yum Server soft

baseurl=http://$yum_server/yum/server

enabled=1
gpgcheck=0
EOF
cp $yum_repo_file $yum_dir/server.repo
echo "yum_repo=http://${yum_server}/yum/server/server.repo" >> ./conf.sh
}
function yum_add {
	file=$1
	if [ ! -e "$file" ];then
		if [ ! -d "$file" ];then
			echo "this is not file or direcoty ."
			exit 1
		fi
	fi
	yum_isset
	if [ $? -ne 0 ];then
		yum_init
		cp -fr  $1 $yum_dir
		yum_create
		yum_repo
	else 
		cp -fr  $1 $yum_dir
		yum_update
	fi
}
function yum_download {
	name=$1
	yum_isset
	if [ $? -ne 0 ];then
		yum_init
		yum  -y install $name --downloadonly --downloaddir=$yum_dir 
		yum_create
		yum_repo
		yum_update
	else 
		yum  -y install $name --downloadonly --downloaddir=$yum_dir 
		yum_update
	fi
}
