#!/usr/bin/perl
use info;

my $mongo=info->new;
#my $conn=$mongo->set;
$data={ 
	ip => 192.168.1.201,
	domain_name => '201.youpin.com',
	user => 'root',
	pwd => '123456',
	hard => {
		cpu => '',
		memory => '',
		disk => '',
		network => '',
	},
	soft => {
		os => 'linux',
		type => '64',
		filetype => 'ext3',
		service => {
			mysql => {
				version => 5.5,
				install_dir => '/usr/local/mysql',
				data_dir => '/data',
			},
		},
	},
};
#$conn->insert($data);
$mongo->type('get');
$mongo->domain_name('200.youpin.com');
print $mongo->ip("aaaaaaaa11111");
