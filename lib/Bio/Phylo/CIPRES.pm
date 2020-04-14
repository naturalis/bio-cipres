package Bio::Phylo::CIPRES;
use strict;
use warnings;
use URI;
use Carp;
use XML::Twig;
use MIME::Base64;
use Data::Dumper;
use YAML qw(LoadFile);
use LWP::UserAgent;
use HTTP::Request::Common;
use Bio::Phylo::Util::Logger ':simple';
use Bio::Phylo::Util::Exceptions 'throw';

# package globals
use version; our $VERSION = qv("v0.0.2");
our $AUTOLOAD;

=head1 NAME

Bio::Phylo::CIPRES - Client for the CIPRES analysis portal

=head1 SYNOPSIS

 use Bio::Phylo::CIPRES;
 my $client = Bio::Phylo::CIPRES->new(
	'infile'  => $infile, 
	'info'    => $yml,
	'tool'    => $tool,
	'param'   => \%param,
	'outfile' => \@outfile,	
	'wd'      => $wd, 
 );
 $client->run;

=cut

sub new {
	my $class = shift;
	my $self = bless { map { $_ => undef } qw[infile info tool param outfile wd] }, $class;
	my %args = @_;
	while( my ( $property, $value ) = each %args ) {
		$self->$property($value);
	}
	return $self;
}

sub info {
	my ( $self, $yml ) = @_;
	if ( $yml ) {
		$self->{'info'} = LoadFile($yml);
		return $self;
	}
	else {
		return $self->{'info'};
	}
}

sub run {
	my $self = shift;
	
	# launch the job
	INFO "Going to launch " . $self->tool;
	my $status_url = $self->launch_job;
	
	# poll results
	POLL: while ( 1 ) {
		my $status = $self->check_status( $status_url );
		DEBUG Dumper( $status );
		if ( $status->{'completed'} eq 'true' ) {
			my $outfiles = $status->{'outfiles'};
			my %results = $self->get_results( $outfiles );
			
			#write results
			for my $name ( keys %results ) {
				my $path = $self->wd . '/' . $name;
				open my $fh, '>', $path or die "Couldn't open $path: $!";
				print $fh $results{$name};
				close $fh;
			}
			last POLL;
		}
		sleep 60;
	}
}

sub get_results {
	my ( $self, $outfiles ) = @_;	
	my $ua  = LWP::UserAgent->new;		
	my $res = $ua->request( $self->status_request( $outfiles ) );

	# request was successful
	if ( $res->is_success ) {

		my %outfile;
		for my $name ( @{ $self->outfile } ) {
			$outfile{ $name } = undef;
		}
		
		# parse result
		my $location;
		my $result = $res->decoded_content;
		DEBUG $result;
		XML::Twig->new(
			'twig_handlers' => {
				'results/jobfiles/jobfile' => sub {
					my $node = $_;
					my $name = $node->findvalue('filename');
					if ( exists $outfile{ $name } ) {
						$outfile{ $name } = $node->findvalue('downloadUri/url');
					}
					DEBUG $node->toString;
				}
			}
		)->parse($result);
		
		# fetch output one by one
		for my $name ( keys %outfile ) {
			my $location = $outfile{$name};
			my $output = $ua->request( $self->status_request( $location ) );
			if ( $output->is_success ) {
				$outfile{$name} = $output->decoded_content;
			}
			else {
				ERROR $output->status_line;
				croak;			
			}
		}
		return %outfile;
	}
	else {
		throw 'NetworkError' => $res->status_line;
	}	
}

# for $status_url, checks and returns terminalStage
sub check_status {
	my ( $self, $status_url ) = @_;
	my $ua  = LWP::UserAgent->new;	
	my $res = $ua->request( $self->status_request( $status_url ) );
	
	# parse response
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

# for $status_url, composes request to check status
sub status_request {
	my ( $self, $status_url ) = @_;

	# lookup credentials
	my $user = $self->info->{'CRA_USER'};
	my $pass = $self->info->{'PASSWORD'};
	
	# make request	
	my $request = HTTP::Request::Common::GET(
		$status_url,
		'Authorization' => 'Basic ' . encode_base64("${user}:${pass}"),
		'cipres-appkey' => $self->info->{'KEY'},
	);
	
	DEBUG $request->as_string;
	return $request;
}

sub launch_job {
	my $self = shift;
	my $ua   = LWP::UserAgent->new;
	my $res  = $ua->request( $self->launch_request );

	# process the response
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
		return $status_url;
	}
	else {
		throw 'NetworkError' => $res->status_line;
	}
}

sub launch_request {
	my $self = shift;
	
	# build content
	my %content = (
		'input.infile'         => [ $self->infile ],
		'tool'                 => $self->tool,
		'metadata.statusEmail' => 'true',
	);
	while( my ($k,$v) = each %{ $self->param || {} } ) {
		$content{$k} = $v;
	}
	
	# lookup credentials
	my $user = $self->info->{'CRA_USER'};
	my $pass = $self->info->{'PASSWORD'};	
	
	# make request	
	my $request = HTTP::Request::Common::POST(
		$self->info->{'URL'},
		'Authorization' => 'Basic ' . encode_base64("${user}:${pass}"),
		'Content_Type'  => 'form-data',
		'cipres-appkey' => $self->info->{'KEY'},
		'Content'       => [ %content ],
	);
	
	DEBUG $request->as_string;
	return $request;
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
	# maybe kill process on server?
}

1;

