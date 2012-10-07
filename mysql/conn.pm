package conn;
use Moose;
use Server;
use Data::Dumper;

has host => (is => 'rw');

sub os  {
		my $self=shift;
		my $conn_host=shift;
		my $conn=Server->new(user => $conn_host->{user} ,pwd => $conn_host->{pwd} ,host => $conn_host->{host} );
		return $conn;
}
1
