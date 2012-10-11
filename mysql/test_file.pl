#!/usr/bin/perl
use file;
use Data::Dumper;

my $file=file->new(name=>'./test_puppet.pl');
print $file->array;
