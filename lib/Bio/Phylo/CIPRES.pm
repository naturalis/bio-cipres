package Bio::Phylo::CIPRES;
use strict;
use warnings;
use URI;
use Carp;
use XML::Twig;
use MIME::Base64;
use Data::Dumper;
use HTTP::Request;
use LWP::UserAgent;
use YAML qw(LoadFile);
use Bio::Phylo::Util::Logger ':simple';

# package globals
our $VERSION="0.0.1";
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
		my $status = check_status( $self->info, $status_url );
		DEBUG Dumper( $status );
		if ( $status->{'completed'} eq 'true' ) {
			my $outfiles = $status->{'outfiles'};
			my %results = $self->get_results( 
				'outfiles' => $outfiles, 
				'info'     => $self->info,
#				%args, 
			);
			
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

sub launch_job {
	my $self = shift;	
	my $command = $self->launch_request;

	# run submission, parse result
	my $status_url;	
	my $result = `$command`;
	DEBUG $result;
	XML::Twig->new(
		'twig_handlers' => {
			'jobstatus/selfUri/url' => sub { $status_url = $_->text }
		}
	)->parse($result);
	return $status_url;
}

sub launch_request {
	my $self = shift;
	
	# populate basic user agent
	my $ua = LWP::UserAgent->new;
	
	# build content
	my %content = (
		'input.infile'         => [ $self->infile ],
		'tool'                 => $self->tool,
		'metadata.statusEmail' => 'true',
	);
	while( my ($k,$v) = each %{ $self->param || {} } ) {
		$content{$k} = $v;
	}
	
	# make request	
	my $request = HTTP::Request::Common::POST(
		$self->info->{'URL'},
		'Authorization' => 'Basic ' . encode_base64('user:password'),
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

1;

