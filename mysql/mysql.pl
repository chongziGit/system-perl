#!/usr/bin/perl
package Mysql;
use Moose;
unshift(@INC,"/root/mysql/");
use Server;

has server_attr    =>	(is => 'rw',isa => 'HashRef');
has server_status =>    (is => 'rw',isa => 'Any');
has mysql_attr => 	(is => 'ro',isa => 'HashRef');
has error => {is => 'rw',isa => 'Str'};

sub install {
	my $self=shift;
	my $server_attr=$self->server_attr;
	my $exp=Server->new( $server_attr);
	my $yum_install=[
				''
	];
	my $core_install=[

	];
	$exp->login;
	
	
}
