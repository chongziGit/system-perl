#!/usr/bin/perl
use config;
use Data::Dumper;

my $config=config->new;
my $data=$config->config;
my $s=0;
print Dumper $data;
