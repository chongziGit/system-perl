#!/usr/bin/perl
package puppet;
use Moose;
use Server;
use IO::File;
use File::Path qw/mkpath/;
use File::Copy qw/copy/;
use config;
use Data::Dumper;

extends 'conn','define','error';

has host_domain => (is => 'rw');
has puppet_server => (is => 'rw');

	
sub request {
	my $self=shift;
	my $os=$self->os($self->host);
	my $config=$self->config;
	my $yum_repo=$config->{yum_repo};
	my $puppet_server='puppet' . '.' . $config->{dns_domain};
	$self->puppet_server($puppet_server);
	my $host_domain=$1 . '.' .  $config->{dns_domain} if $os->host =~ /^\d+\.\d+\.\d+\.(\d+)$/;
	print $host_domain,"\n";
	if($host_domain){
		$self->host_domain($host_domain);
		$os->login;
		$self->error($os->error) if $os->error;
		my $cmd=[
				"wget $yum_repo -P /etc/yum.repos.d/",
				'yum -y install puppet',
				"puppetd --test --server $puppet_server"
		];
		$os->exec_cmd($cmd);
		$self->error($os->error) if $os->error;
		$os->close;
	}
	
}

sub response {
	my $self=shift;
	my $os=$self->os($self->host);
	my $host_domain=$self->host_domain;
	my $puppet_server=$self->puppet_server;
	$self->error("puppet add $host_domain error") if system("./puppet.sh add $host_domain");
	$os->login;
	$self->error($os->error) if $os->error;
	my $cmd=["puppetd  --test --server $puppet_server "];
	$os->exec_cmd($cmd);
	$self->error($os->error) if $os->error;
	$os->close;
	
}
sub create {
	my $self=shift;
	my $config=$self->config;
	my $conf=config->new;
	my $puppet_dir=$config->{puppet_dir};
	my $puppet_module= $puppet_dir . 'moules/';
	my $puppet_module_pp=$puppet_dir . 'mysql/'  . 'manifests/'; 
	my $puppet_pp=$puppet_dir . 'manifests/';
	my $puppet_conf_pp='.pp';
	my $puppet_pp_mysql=$puppet_pp . 'mysql' . $puppet_conf_pp;
	my $mysql_conf=$config->{conf_path} . 'my.cnf';
	my $mysql_puppet_conf_path=$puppet_module . 'mysql/files' .$config->{conf_path};
	my $mysql_puppet_conf=$mysql_puppet_conf_path . 'my.cnf';
	my $mysql_pp=IO::File->new(">$puppet_pp_mysql");
	$self->add_config('mysql_puppet_conf_path' ,$mysql_puppet_conf_path);
	print $mysql_pp <<EOF;
		node '\\d+\\.$config->{dns_domain}' {
        		include mysql
		}
EOF
	mkpath $puppet_module_pp unless -d $puppet_module_pp;
	mkpath $mysql_puppet_conf_path unless -d $mysql_puppet_conf_path;
	my $puppet_module_mysql=$puppet_module_pp . 'init' . $puppet_conf_pp;
	my $mysql_module_pp=IO::File->new(">$puppet_module_mysql");
	my $mysql_conf_puppet=qw#puppet:///mdules/mysql/my.cnf#;
	print $mysql_conf_puppet,"\n";
	print $mysql_module_pp <<EOF;
	class mysql {
        	file {
                	"$mysql_conf":
                	owner => 'root'
                	group => 'root',
                	mode => 0440,
                	source => "$mysql_conf_puppet"
        	}
	}
EOF

	$conf->config;
	$conf->save($mysql_puppet_conf);
}
1
