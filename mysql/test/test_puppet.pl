#!/usr/bin/perl
unshift(@INC,"/root/mysql/");
use Data::Dumper;
require puppet;

my $host={
	user => 'root',
	pwd => '123456',
	host => '192.168.100.201',
};
	my $puppet=puppet->new(host => $host);
	$puppet->request;
	$puppet->response;
