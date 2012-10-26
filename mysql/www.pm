#!/usr/bin/perl
package www;
use Moose;
use LWP;

extends 'error','debug';

has 'agent' => ( is => 'rw');
has 'url' => (is => 'rw');

sub _init {
	my $self=shift;
	my $agent=LWP::UserAgent->new;	
	$self->agent($agent);
}

sub get {
	my $self=shift;
	my $url=shift || $self->url;
	my $agent=$self->agent || $self->_init;
	my $response;
	eval {
		$response=$agent->get($url);
	};
	unless ($response->is_success) {
		$self->error($response->status_line);
		return 0;
	}
	return $response->decoded_content;
}

sub post {
	my $self=shift;
	my $url=shift || $self->url;
	my $arg=shift || [];
	my $agent=$self->agent || $self->_init;
	my $response;

	eval {
		$response=$agent->post($url,$arg);
	};

	$self->dumper($response);

	unless($response->is_success){
		$self->error($response->status_line);
		return 0;
	}

	return $response->decoded_content;
}
1;
