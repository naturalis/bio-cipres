package Bio::Phylo::CIPRES;
use strict;
use warnings;
use URI;
use Carp;
use XML::Twig;
use Data::Dumper;
use LWP::UserAgent;
use YAML qw(LoadFile);
use Bio::Phylo::Util::Logger ':simple';
use Bio::Phylo::Util::Exceptions 'throw';

=head1 NAME

Bio::Phylo::CIPRES - Reusable components for CIPRES REST API access

=cut

# global constants
our $AUTOLOAD;
use version; our $VERSION = qv("v0.1.2");
my $REALM = "Cipres Authentication";
my $PORT  = 443;

sub new {
	my $class  = shift;
	my @fields = qw[infile tool param outfile url user pass cipres_appkey];
	my $self   = bless { map { $_ => undef } @fields }, $class;
	my %args   = @_;
	while( my ( $property, $value ) = each %args ) {
		$self->$property($value);
	}
	return $self;
}

sub run {
	my $self = shift;
	my $url  = $self->launch_job;
	while(1) {
		sleep(60);
		my $status = $self->check_status($url);
		if ( $status->{'completed'} eq 'true' ) {
			return $self->get_results( $status->{'outfiles'} );
		}
	}
}

sub launch_job {
	my $self = shift;
	my $ua   = $self->ua;
	my $url  = $self->url;
	my $load = $self->payload;
	my @head = $self->headers(1);
	my $res  = $ua->post( $url . '/job/' . $self->user, $load, @head );
	if ( $res->is_success ) {
	
		# run submission, parse result
		my $status_url;	
		my $result = $res->decoded_content;
		DEBUG $result;
		XML::Twig->new(
			'twig_handlers' => {
				'jobstatus/selfUri/url' => sub { $status_url = $_->text }
			}
		)->parse($result);
		INFO "Job launched at $status_url";
		return $status_url;	
	}
	else {
		throw 'NetworkError' => $res->status_line;	
	}
}

sub check_status {
	my ( $self, $url ) = @_;
	INFO "Going to check status for $url";
	my $ua   = $self->ua;
	my @head = $self->headers(0);
	my $res  = $ua->get( $url, @head );
	if ( $res->is_success ) {
	
		# post request, fetch result
		my ( $status, $outfiles );
		my $result = $res->decoded_content;
		DEBUG $result;
		XML::Twig->new(
			'twig_handlers' => {
				'jobstatus/resultsUri/url' => sub { $outfiles = $_->text },
				'jobstatus/terminalStage'  => sub { $status   = $_->text }			
			}
		)->parse($result);
		my $time = localtime();
		INFO "[$time] completed: $status";
		return { 'completed' => $status, 'outfiles' => $outfiles };	
	}
	else {
		throw 'NetworkError' => $res->status_line;	
	}	
}

sub get_results {
	my ( $self, $url ) = @_;	
	my %out  = map { $_ => undef } @{ $self->outfile }; 
	my $ua   = $self->ua;
	my @head = $self->headers(0);
	my $res  = $ua->get( $url, @head );
	if ( $res->is_success ) {
		my $result = $res->decoded_content;
		DEBUG $result;
		XML::Twig->new(
			'twig_handlers' => {
				'results/jobfiles/jobfile' => sub {
					my $node = $_;
					my $name = $node->findvalue('filename');
					if ( exists $out{ $name } ) {
						$out{ $name } = $node->findvalue('downloadUri/url');
					}
					DEBUG $node->toString;
				}
			}
		)->parse($result);
		for my $name ( keys %out ) {
			my $location = $out{$name};
			$res = $ua->get( $location, @head );
			if ( $res->is_success ) {
				$out{$name} = $res->decoded_content;
			}
			else {
				throw 'NetworkError' => $res->status_line;	
			}
			return %out;
		}		
	}
	else {
		throw 'NetworkError' => $res->status_line;	
	}
}

sub yml {
	my ( $self, $yml ) = @_;
	INFO "Reading YAML file $yml";	
	my $info = LoadFile($yml);
	DEBUG "Parsed " . Dumper( $info );
	$self->user( $info->{'CRA_USER'} );
	$self->pass( $info->{'PASSWORD'} );
	$self->url( $info->{'URL'} );
	$self->cipres_appkey( $info->{'KEY'} );
}

sub ua {
	my $self = shift;
	my $host = URI->new( $self->url )->host();
	my $user = $self->user;
	my $pass = $self->pass;
	my $ua   = LWP::UserAgent->new;
	INFO "Instantiating UserAgent $host:$PORT / $REALM / $user:****";
	$ua->ssl_opts( 'verify_hostname' => 0 );
	$ua->credentials(
		$host . ':' . $PORT,
		$REALM,
		$user => $pass
	);
	return $ua;
}

sub payload {
	my $self = shift;
	INFO "Composing payload for ".$self->tool." with infile ".$self->infile;
	my $load = [
		'tool'                 => $self->tool,
		'input.infile_'        => [ $self->infile ],
		'metadata.statusEmail' => 'true',
		%{ $self->param }
	];
	DEBUG Dumper($load);
	return $load;
}

sub headers {
	my ( $self, $form ) = @_;
	if ( $form ) {	
		INFO "Composing POST / form-data headers";	
		return (
			'Content_Type'  => 'form-data',
			'cipres-appkey' => $self->cipres_appkey,
		);
	}
	else {
		INFO "Composing GET headers";
		return ( 'cipres-appkey' => $self->cipres_appkey );
	}
}

sub AUTOLOAD {
	my ( $self, $arg ) = @_;
	my $property = $AUTOLOAD;
	$property =~ s/.*://;
	if ( exists $self->{$property} ) {
		if ( $arg ) {
			$self->{$property} = $arg;
			return $self;
		}
		else {
			return $self->{$property};
		}
	}
	else {
		my $template = 'Can\'t locate object method "%s" via package "%s"';		
		croak sprintf $template, $property, __PACKAGE__;
	}
}

sub DESTROY {
	# maybe kill and delete process on server?
}

1;
