#!/usr/bin/perl
package debug;
use Moose;
use Data::Dumper;
use Perl6::Say;

has 'debug' => (is => 'rw');

sub dumper {
	my $self=shift;
	my $data=shift;

	if(ref $data){
		print Dumper $data;
	}
	else {
		print($data);
	}
}
1
