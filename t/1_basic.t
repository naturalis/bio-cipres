use strict;
use warnings;
use Test::More;

require_ok( 'Bio::Phylo::CIPRES' );

my %args = (
	'infile'  => $0, 
	'tool'    => 'MAFFT_XSEDE',
	'param'   => { 'vparam.anysymbol_' => 1 },
	'outfile' => [ 'output.mafft' ],	
	'wd'      => '.', 
);

my $obj = new_ok( 'Bio::Phylo::CIPRES' => [ %args ] );

while( my ( $property, $expected ) = each %args ) {
	my $observed = $obj->$property;
	is_deeply( $observed, $expected );
}

$obj->{'info'} = {
	'URL'      => 'https://cipresrest.sdsc.edu/cipresrest/v1',
	'KEY'      => 'Bio::Phylo::CIPRES',
	'CRA_USER' => 'rvosa',
	'PASSWORD' => 'fakePassword',
};

isa_ok( $obj->launch_request, 'HTTP::Request' );

isa_ok( $obj->status_request( 'http://example.org' ), 'HTTP::Request' );

eval { $obj->launch_job };
isa_ok( $@, 'Bio::Phylo::Util::Exceptions::NetworkError' );

eval { $obj->check_status };
isa_ok( $@, 'Bio::Phylo::Util::Exceptions::NetworkError' );

done_testing();
