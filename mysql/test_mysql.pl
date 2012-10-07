#!/usr/bin/perl
use install;

my $host = {
	user => 'root',
	host => '192.168.11.111',
	pwd  => '123456',
};
my $install = install->new(host => $host);
$install->source;
