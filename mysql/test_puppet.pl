#!/usr/bin/perl
unshift(@INC,"/root/mysql/");
use Data::Dumper;
use puppet;
my $host={
	user => 'root',
	pwd => '123456',
	host => '192.168.11.111',
};
	my $puppet=puppet->new(host => $host);
	#$puppet->request;
	#$puppet->response;
	$puppet->create;
