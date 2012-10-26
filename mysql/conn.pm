package conn;
use Moose;
use Server;
use MongoDB;
use DBIx::Simple;

extends 'error','debug';

has host => (is => 'rw');

sub os  {
		my $self=shift;
		my $conn_host=shift || {user => 'root',pwd => 123456,host => 192.168.1.201};
		my $conn;
		eval {
			$conn=Server->new(user => $conn_host->{user} ,pwd => $conn_host->{pwd} ,host => $conn_host->{host} ) || warn "连接 $conn_host->{host} 失败 : $self->error";
		};
		if($@) {
			$self->error($@);
			return 0;
		}
		return $conn;
}
sub mongo {
		my $self=shift;
		my $host=shift || 'localhost';
		my $port=shift || '27017';
		my $conn;

		eval {
			$conn=MongoDB::Connection->new(host => $host, port => $port) || warn "连接 $host 失败";
		};
		if($@){
			$self->error($@);
			return 0;
		}
		return $conn;
}

sub mysql {
	my $self=shift;
	my $conn_host=shift || {user => 'youpin',pwd => 'ZHNnZmRnZmtybGV3PTR6Cg==' ,host => '192.168.0.108',port => '3379',db => '51youpin',type => 'mysql'};
	my $conn;
	eval {
		$conn=DBIx::Simple->connect(
		       "DBI:$conn_host->{type}:database=$conn_host->{db};host=$conn_host->{host}:$conn_host->{port}",
			"$conn_host->{user}","$conn_host->{pwd}",
			{ RaiseError => 1 } 
		) || warn "连接 $conn_host->{host} 失败 : $conn->error";
	};
	if ($@){
		$self->error($@);
		return 0;
	}
	return $conn;
}
1
