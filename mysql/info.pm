#!/usr/bin/perl
package info;
use Moose;

has domain_name => (is => 'rw');
has 

=pod
domain_name => {
		IP => '',
		comment => '',
		user => {
			'name' => '',
			'pwd'  => '',
		},
		hard => {
			cpu => '',
			memory => '', 
			disk => '',
			network => '',
		}
		soft => {
			os => '',
			filetype => '',
			swap => ''
			service => {
				mysql => {
					user => '',
					group =>'',
					port => '',
					protocol => '',
					install_dir => '',
					service_shell => '',
					data_dir => '',
					log_dir => '',
					version => '',
					
				}
			}
		}
}
=cut
sub set {

} 
