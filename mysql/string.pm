#!/usr/bin/perl
package string;
use Moose;
use Scalar::Quote;
use Digest::MD5;
use Aut::Base64;


has 'str' => (is => 'rw');

sub trim {
	my $self=shift;
	my $str=shift || $self->str;
	my $sp=shift || '\s';
	$str=~s/^$sp+//g;
	$str=~s/$sp+$//g;
	$self->str($str);
	return $str;	
}

sub quote {
	my $self=shift;
	my $str=shift || $self->str;
	return Scalar::Quote::quote($str);
}

sub md5 {
	my $self=shift;
	my $str=shift || $self->str;
	return Digest::MD5::md5_hex($str);
}

sub base64 {
	my $self=shift;
	my $str=shift || $self->str;
	my $base_type=shift || 'encode';
	my $base=Aut::Base64->new;
	if ($base_type eq 'encode' ){
		return $base->encode($str);
	}
	elsif ($base_type eq 'decode') {
		return $base->decode($str);
	}
	else {
		return 0;
	}
}

sub type {
	my $self=shift;
	my $str=shift || $self->str;
	$str / 1 ? return 'String' : return 'Numeric';
}

sub utf8 {
	my $self=shift;
	my $str=shift || $self->str;
	my $str_utf8=decode_utf8($str);
	$self->str($str_utf8);
	return $str_utf8;
}
1
