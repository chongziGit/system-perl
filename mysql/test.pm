#!/usr/bin/perl
use Moose;
use Test::More;
use Net::Ping;

has os  =>  (is => 'rw' );
has net => ( is => 'rw');
has dns => ( is => 'rw');
has yum => ( is => 'rw');
has error => (is => 'rw');

sub os_name {
	my $self=shift;
	$self->os($^O);	
}

sub net {
	$p = Net::Ping->new();
	$addr='61.135.169.125';
	$p->ping($addr) ? return 1 : return 0;
	$p->close();
}
