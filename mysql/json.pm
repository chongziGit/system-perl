#!/usr/bin/perl
package json;
use Moose;
use JSON qw/encode_json decode_json/;
use Data::Types qw/is_string is_int is_float/;

extends 'error';

sub json {
        my $self=shift;
        my $data=shift;
        if(ref $data eq 'HASH' || ref $data eq 'ARRAY'){
                my $data_j=encode_json($data); 
                return $data_j;
        }       
        elsif(is_string($data)  || is_int($data)  || is_float($data)){
                my $json=[];
                push @{$json},$data;
                my $data_j=encode_json($json);
                return $data_j;
        }
        else {
                return 0;
        }
}

sub unjson {
        my $self=shift;
        my $data=shift;

        if ( is_string($data)){
                my $data_f=decode_json($data);
                $data_f ? return $data_f : return 0;
        }
        return 0;
}
1;

