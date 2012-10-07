#!/usr/bin/perl
package define;
use Moose;
use IO::File;
use Data::Dumper;

has config => (is => 'rw',builer => '_parse');
has 'conf' => ( is =>'rw',default => '/root/mysql/conf.sh');

sub _parse {
	my $self=shift;
	my $file=$self->conf;
	my $fh=IO::File->new("$file");
	my %config;
	while(<$fh>){
		chomp;
		my($key,$value)=split '=',$_;
		next unless $key =~ /^\w+_\w+$/;
		$value=~s/'?"//g;
		$config{$key}=$value;	
	}
	$fh->close;
	return \%config;
	print Dumper \%config;
}
sub add_config {
	my $self=shift;
	my $cmd=shift;
	my $value=shift;
	my $file=$self->conf;
	my $fh=IO::File->new(">>$file");
	my $data=$cmd . '=' . $value;
	print $fh $data,"\n";
	$fh->close;	
}
1
