#!/usr/bin/perl
package file;
use Moose;
use Tie::File;
use string;

has name => (is =>'rw');

sub array {
        my $self=shift;
        my $name=$self->name || return 0;
        my $str=string->new;
        my @data;
        tie(@data,'Tie::File',$name,autochomp => 1);
        foreach(@data){
                $_=$str->utf8($_);
        }
        return \@data;
}
1
