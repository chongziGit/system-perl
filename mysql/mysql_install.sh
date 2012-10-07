#!/bin/bash
source ./yum.sh
version=$1
download_url=$2
mysql_parameter=$3
source_dir='/usr/src/redhat/'
source_rpm_dir="$source_dir/RPMS"
download_dir="$source_dir/SOURCES/"
unzip_dir='/usr/src/local/'
soft_name=$(basename "$download_url")

export CXXFLAGS="-O3 -felide-constructors -fno-exceptions -fno-rtti"

function isset_dir {
		[ -d "$download_dir" ] || mkdir $download_dir
		[ -d "$unzip_dir" ] || mkdir $unzip_dir
}

function download_file {
	local url=$1
	download_name=`basename $url`
	wget $url -P $download_dir/
	tar zxf $download_dir/$download_name -C $unzip_dir
}

function tar_rpm {
	name=$1
	build_root_dir=$2
	config_par=$3
	cpu_num=`cat /proc/cpuinfo | grep processor | wc -l`
	make_par="make -j $cpu_num"
	rpm_name=` echo  $name | grep -o '^[a-zA-Z]*'`
	rpm_version=`echo $name | grep -o '[0-9]*\.[0-9]*\.[0-9]*'`
	create_file="${rpm_name}.spec"

cat > $create_file <<EOF
###############################################################
%define build_root_dir $build_root_dir
# 需要包的名称
name: $rpm_name
# 包的版本信息
Version: $rpm_version
# 释放版本号
Release: 1
# 创建者
Packager: chongzi
# 摘要信息
Summary: by mysql install 
# 所属组
group: System Environment/Daemons
# 公共许可证
License: GPL
# 指定包目标环境平台（i386对应32系统，x86_64对应64系统，noarch不区分系统）
exclusiveArch: i386
# 安装目录
buildroot: %{_tmppath}/%{name}-%{version}-%{release}-build
#制定编译源代码文件
source: %{name}-%{version}.tar.gz
# 描述信息
%description
this is a mysql install rpm package 
%prep
%setup -q
%build
$config_par
$make_par
%install
make install PREFIX=\$RPM_BUILD_ROOT/%{build_root_dir}
mkdir -p \$RPM_BUILD_ROOT/%{build_root_dir}
cp -afrp %{build_root_dir}/*  \$RPM_BUILD_ROOT/%{build_root_dir} 
%clean
rm -fr $build_root_dir
rm -fr \$RPM_BUILD_ROOT/%{build_root_dir} 
%files
%defattr(-,root,root)
%{build_root_dir}
%exclude %{build_root_dir}/mysql-test
%exclude %{build_root_dir}/sql-bench
EOF
	rpmbuild -bb $create_file
	install_soft_name=`find $source_dir/RPMS -type f | grep $rpm_name-$rpm_version`
	yum_add $install_soft_name
}

function mysql_5_5 {
	isset_dir
	yum -y install cmake
	cmake_status=0
	download_file $download_url
	[ "$mysql_parameter" == '' ] && mysql_parameter="cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DWITH_INNOBASE_STORAGE_ENGINE=1 "
	install_dir=`echo $mysql_parameter  | perl -e 'chomp($_=(<>));print $1,"\n" if /PREFIX=([^\s]*)\s+/'`
	tar_rpm "$soft_name"   "$install_dir"  "$mysql_parameter"
}

function mysql_5_1 {
	isset_dir
	#download_file $download_url
	[ "$mysql_parameter" == '' ] && mysql_parameter=' ./configure  --prefix=/usr/local/mysql --enable-assembler --with-mysqld-ldflags=-all-static   --with-charset=utf8  '
	install_dir=`echo $mysql_parameter  | perl -e 'chomp($_=(<>));print $1,"\n" if /prefix=([^\s]*)\s+/'`
	tar_rpm "$soft_name"  "$install_dir" "$mysql_parameter"
}

if [  "$version" == '' ] || [ "$download_url" == '' ];then
	exit 1
fi

case $version in
5.5)
	mysql_5_5
	;;
5.1)	mysql_5_1
	;;
*)
	exit 1
	;;
esac	
