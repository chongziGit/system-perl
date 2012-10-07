#!/usr/bin/perl
package install;
use Moose;
use Moose::Util::TypeConstraints qw( subtype where message enum);
use Server;
use define;
use Data::Dumper;

extends 'conn','define','error';

has 'type' => ( 
		is => 'rw',
		isa => subtype (
				'Str', enum( 
						[qw(yum source),]
				) => message { 
						"$_ 必须是 yum 或者source 其中之一"}
		      )
	      );

sub init {
	my $self=shift;
	my $os=$self->os($self->host);
	my $config=$self->config;
	print Dumper $self;
	my $os_domain=$os->{host};
	my $host_domain=$os_domain . '.' . $config->{dns_domain};
	$os_domain=~s/(.*)\.(\d+)\.(\d+)$/$3/;
	$self->error('new add domain $os_domain error')	if system("./dns.sh add $os_domain");
	$os->login;
	$self->error($os->error) if $os->error;
	my $yum_tools=[
				"yum -y groupinstall 'Development Libraries'",
				"yum -y groupinstall 'Development Tools'",
				"hostname $host_domain",
				'yum -y install puppet',
				"echo 'nameserver $config->{dns_server}' >> /etc/resolv.conf ",
				'/etc/init.d/network reload'
		      ];
	$os->exec_cmd($yum_tools);
	$self->error($os->error) if $os->error;
}

sub yum {
	my $self=shift;
	my $version=shift || '5.1';
	my $client=shift || 'yes';
	my $os=$self->os($self->host);
	$os->login;
	$self->error($os->error) if $os->error;
	$self->error("此版本不支持,默认只支持5.1或者5.5版本") unless $version =~ /^5\.[15]$/;
	my $cmd= { 5.1 => [
				'yum -y install mysql-server mysql'
			  ],
		   5.5 => [
				'rpm -Uvh http://repo.webtatic.com/yum/centos/5/latest.rpm',
				'yum -y install http://www.ha97.com/tag/server --enablerepo=webtatic',
			  ],
		};
	$os->exec_cmd($cmd->{$version});
	$self->error($os->error) if $os->error;
}
sub  source {
	my $self=shift;
	my $version=shift || '5.1.60';
	my $os=$self->os($self->host);
	$self->error("此版本不支持，或者版本格式不正确，例如: 5.X.X") unless $version =~ /^[45]\.\d+\.\d+$/;
	my $master_version=$1 if $version=~/^(\d\.\d+)/;
	my $download_dir='~/soft';
	my $mysql_url='http://download.softagency.net/MySQL/Downloads/MySQL-' . $master_version . '/mysql-' .  $version . '.tar.gz';
	
	print $mysql_url,"\n";
	$self->error("create rpm file error ") if system("./mysql_install.sh $master_version $mysql_url");
	my $cmd = {
		5.1 => [
				"yum -y install mysql-$version"
		],
		5.5 => [
				'yum -y install cmake',
				"yum -y install mysql-$version",
		],
	};
	$os->login;
	$self->error($os->error) if $os->error;
	$os->exec_cmd($cmd->{$master_version});		
		
}
1;
