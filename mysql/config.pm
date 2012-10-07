#!/usr/bin/perl
package config;
use Moose;
use IO::File;
use string;
use Data::Dumper;

has 'conf' => (is => 'rw',default => './my.cnf');
has 'data' => (is =>'rw');

sub config {
	my $self=shift;
	my $conf=$self->conf;
	my $cnf=IO::File->new($conf);
	my $config=[];
	_parse($cnf,0,$config);
	$self->data($config);
	return $config;
}

sub add {
	my $self=shift;
	my $data=$self->data;
	my $zone=shift;
	my $cmd=shift;
	my $value=shift;
	my $line;
	my $data_ary=&_select($data,$zone);
	return 0 unless $data_ary;
	if($value){
		$line={$cmd => {value => $value } };
	}
	else {
		$line={$cmd => {}};
	}
	push @{$data_ary},$line;
}

sub delete {
	my $self=shift;
	my $data=$self->data;
	my $zone=shift;
	my $cmd=shift;
	my $i=0;
	my $data_ary=&_select($data,$zone);
	return 0 unless $data_ary;
	foreach(@{$data_ary}){
		my $data_hash=$_;
		foreach (keys(%{$data_hash})){
			$i++;
			last if $_ eq $cmd;
		}
	}
	delete $data_ary->[$i];
}

sub update {
	my $self=shift;
	my $data=$self->data;
	my $zone=shift;
	my $cmd=shift;
	my $value=shift;
	my $data_ary=&_select($data,$zone);
	return 0 unless $data_ary;
	foreach(@{$data_ary}){
		my $data_hash=$_;
		foreach (keys(%{$data_hash})){
			$data_hash->{$_}->{value}=$value if $_ eq $cmd;
		}
	}
}

sub comment {
	my $self=shift;
	my $data=$self->data;
	my $zone=shift;
	my $cmd=shift;
	my $value=shift;
	my $data_ary=&_select($data,$zone);
	return 0 unless $data_ary;
	foreach(@{$data_ary}){
		my $data_hash=$_;
		foreach (keys(%{$data_hash})){
			$data_hash->{$_}->{comment}=$value if $_ eq $cmd;
		}
	}
}

sub save {
	my $self=shift;
	my $config_file=shift || './my.cnf';
	my $data=$self->data;
	my $file=IO::File->new(">$config_file");
	foreach(@{$data}){
		my $zone=$_;
		foreach (keys(%{$zone})){
			my $lines=$zone->{$_};
			print $file $_,"\n";
			my $cmd;
			foreach (@{$lines}){
				my $line=$_;
				foreach (keys(%{$line})){
					if (exists $line->{$_}->{value}){
						$cmd=$_ . '=' . $line->{$_}->{value};
					}
					else {
						$cmd=$_ ;
					}
					print $file $cmd,"\n";
				}
			}
		}
	}
	$file->close;
}

sub _parse {
	my $fh=shift;
	my $byte=shift;
	my $config=shift;
	my $str=string->new;
	seek $fh,$byte,0;
	my $status=0;
	my $f={};
	my $key;
	while(<$fh>){
		chomp;
		next if /^$/;
		if (/^(\[.*\])/){
			if ($status == 0 ){
				my $tmp_key=$1;
				$key=$str->trim($tmp_key);
				$f->{$key}=[];		
				push @{$config},$f ;
				$status++;
				next;
			}
			my $tell_byte=tell ;
			my $start_byte = $tell_byte - length("$_\n");
			&_parse($fh,$start_byte,$config) if $status == 1;
		}	
		if( $key  && $_ && exists  $f->{$key}){
			my $c={};
			if (/^(.+)=(.+)$/){
				$c->{$str->trim($1)}->{'value'}=$str->trim($2);
			}
			else {
				$c->{$str->trim($_)}={};
			}
			push @{$f->{$key}},$c;
		}

	}
}

sub _select {
	my $value=shift;
	my $key=shift;
	return 0 unless ref $value eq 'ARRAY';
	foreach(@{$value}){
		return 0 unless ref $_ eq 'HASH';
		my $data=$_;
		foreach(keys(%{$data})){
			return $data->{$_} if $_ eq $key;
		}
	}
	return 0;
}

1
