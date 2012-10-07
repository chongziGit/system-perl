#!/usrrbin/perl
unshift(@INC,"/root/mysql/");
use Data::Dumper;
use install;
$data={
  user => 'root',
  pwd  => '123456',
  host => '192.168.1.201'
};
$install=install->new(host => $data);
$install->source;
