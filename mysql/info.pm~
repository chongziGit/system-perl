#!/usr/bin/perl
package info;
use Moose;
use Data::Dumper;

extends 'conn','error';

has 'type' => (is => 'rw');
has 'conn' => (is => 'rw');
has 'domain_name' => (is => 'rw');

sub set {
	my $self=shift;
	my $mongo=$self->mongo;
	my $conn=$mongo->mysql->server;
	$self->conn($conn);
	return $conn;
}

sub _type {
	my $self=shift;
	my $class={set => 1,get => 0};
	my $type=$class->{$self->type};
	$self->error("unkown type : $self->type") unless $type;
	return $type;
}
sub  base {
	my $self=shift;
	my $ip=shift;
	my $domain_name=$self->domain_name;
	my $conn=$self->conn || $self->set;
	my $type=$self->_type;
	my $data;
	if ($type){
		$data=$conn->update({"domain_name" => $domain_name},{ '$set' => {"ip" => $ip}},{'upsert' => 1});
		return $data;;	
	}
	else {
		$data=$conn->find({"domain_name" => $domain_name},{ip => 1});
		while(my $doc = $data->next){
			return $doc->{ip};
		}
	}
	return 0;
}

1

