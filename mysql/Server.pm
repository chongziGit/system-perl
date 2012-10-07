#!/usr/bin/perl
package Server;
use Moose;
use Expect;
use Scalar::Quote;
use Try::Tiny;
use define;
use Data::Dumper;

extends 'error';

has 'host'  =>  ( is => 'rw');
has 'user'  =>  ( is => 'rw');
has 'pwd'   =>  ( is => 'rw');
has 'exp'   =>  ( is => 'rw');

sub login {
	my $self=shift;
	my $user=$self->user;
	my $host=$self->host;
	my $pwd=$self->pwd;
	my $cmd=qq#ssh -l $user $host#;
	my $exp;

	try {
		$exp = Expect->spawn($cmd) or die "can't create spawn "; 
		$self->exp($exp);
		$exp->expect(1,[
                    qr/password:/i => 
                    sub {
                            my $self = shift ;
                            $self->send("$pwd\n");
                            exp_continue;

                        }
                  ],
                  [
                    'connecting (yes/no)?',
                    sub {
                            my $self = shift;
			    $self->send("yes\n");
			    $self->send("$pwd\n");
                            exp_continue;
                         }
                  ]
               ) or die "can't expect login : $!";

	}catch {
		$self->error("Expect login error : $!");
	};
}

sub exec_cmd {
	my $self=shift;
	my $cmd=shift;
	my $prompt=shift || '#';
	my $exp=$self->exp;
	push (@{$cmd},'');
	try {
		foreach(@$cmd){
			s/\n$//;
			my $command=$_;
			$command=Scalar::Quote::quote($_) if $command =~ /'?"/;
			$exp->send("$command\n") or warn "$command exec error" if ($exp->expect(undef,$prompt));
		}
	}catch {
		$self->error("Expect exec command error : $_");
	}finally {
		$self->close;
	};

}

sub close {
	my $self=shift;
	my $exp=$self->exp;
	print Dumper $self;
	$exp->soft_close;
}
1;
