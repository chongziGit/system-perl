###############################################################
%define build_root_dir /usr/local/mysql
# 需要包的名称
name: mysql
# 包的版本信息
Version: 5.1.60
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
 ./configure  --prefix=/usr/local/mysql --enable-assembler --with-mysqld-ldflags=-all-static   --with-charset=utf8  
make -j 1
%install
make install PREFIX=$RPM_BUILD_ROOT/%{build_root_dir}
mkdir -p $RPM_BUILD_ROOT/%{build_root_dir}
cp -afrp %{build_root_dir}/*  $RPM_BUILD_ROOT/%{build_root_dir} 
%clean
rm -fr /usr/local/mysql
rm -fr $RPM_BUILD_ROOT/%{build_root_dir} 
%files
%defattr(-,root,root)
%{build_root_dir}
%exclude %{build_root_dir}/mysql-test
%exclude %{build_root_dir}/sql-bench
