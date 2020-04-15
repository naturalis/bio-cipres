#!/usr/local/bin/perl

# Use the following packages
use Config::Properties;
use LWP;
use URI;
use Env;
# Include the following environent path variables
use Env qw(PATH HOME TERM SDK_VERSIONS PYCIPRES); 

# Written by Anthony Lopez
# CIPRES REST Demo

# The variables used throughout the program --------------------------
my $USR = "";
my $URL = "";
my $PASSWORD = "";
my $APP_ID = "";
my $REALM = "Cipres Authentication";
my $SERVER = "";
my $PORT = 443;
my $TOOL = "";
my $INPUT = "";
my @ns_headers;
my $REQ_TYPE = "";
my $url = "";
my $RESULTS_FILE = "";
my $JOB_NAME = "";
my $EMAIL = "";
my $EMAIL_ADDR = "";
my $JOB_ID = "";
my $TREE = "";
my $TREE_FILE = "";
my $APP_NAME = "";
my $fh = "";
#---------------------------------------------------------------------
# Properties from Configuration File
# URL
# PERL_EX_APPNAME = 
# PERL_EX_APPID = 
# PERL_EX_USERNAME = 
# PERL_EX_PASSWORD =

# look into the directories to find the configuration file. 
# Read and store the values into the corresponding variables. 

# Need to look into the two directories - $SDK_VERSIONS/testdata/, 
# and $HOME/. Need to also see if $PYCIPRES is defined for the file's url. 

# Build the URLs to open up the configuration file. 
my $SDK_VERSIONS_URL = $SDK_VERSIONS . "/testdata/pycipres.conf";
my $HOME_URL = $HOME . "/pycipres.conf";

print "Now checking the directory $SDK_VERSIONS_URL for pycipres.conf \n";
open $fh, '<', $SDK_VERSIONS_URL;
print "Now checking the directory $HOME_URL for pycipres.conf \n";
open $fh, '<', $HOME_URL;
print "Now checking the directory $PYCIPRES for pycipres.conf \n";
# Check the PYCIPRES file and 
#if($PYCIPRES ne ""){
#	print "We are opening the pycipres file from $PYCIPRES \n";
#	open $fh, '<', $PYCIPRES;
#}

# Open up the properties from the configuration file. 
 my $properties = Config::Properties->new();
 $properties->load($fh);

# Get each of the key value pairs. 
$URL = $properties->getProperty(URL);
$USR = $properties->getProperty(PERL_EX_USERNAME);
$PASSWORD = $properties->getProperty(PERL_EX_PASSWORD);
$APP_ID = $properties->getProperty(PERL_EX_APPID);
$APP_NAME = $properties->getProperty(PERL_EX_APPNAME); 

# Check if these are all non-null values
die "The configuration file is missing properties. Please make sure that
the PERL_EX_USERNAME, PERL_EX_PASSWORD, PERL_EX_APPID, and PERL_EX_APPNAME key, value pairs 
are all defined \n" 
if $URL eq "" || $USR eq "" || $PASSWORD eq "" || $APP_ID eq "" || $APP_NAME eq "";

# Authenticate the user by querying for username and password
# Then prompt user for specific command

# The server, port, realm, user and password
# In order to authenticate the user, build the credentials
# The authorization credentials required are in the form of:
#  $browser->credentials(
#    'servername:portnumber',
#    'realm-name',
#    'username' => 'password'
#  );

# Parse using regular expressions, the URL to obtain the SERVER
my $url = URI->new($URL);
$SERVER = $url->host();
print "Hostname: ", $url->host() , "\n";

my $browser = LWP::UserAgent->new;
$browser->ssl_opts(verify_hostname => 0);
$browser->credentials(
	$SERVER . ':' . $PORT,
	$REALM,
	$USR => $PASSWORD
);

# Query for the type of command that the user wishes to do
print "What would you like to do? Valid commands are: \n";
print "List Jobs (LJ); Submit Job (S); Delete Job (D); List Results (LR); \n";
print "Download Results (DR); Get Tools (GT); Exit (E) \n";
# Keep on querying until the command is a valid command
LINE: while(1){
	$COMMAND = <STDIN>;
	chomp($COMMAND);
	print "User typed $COMMAND\n";
	# Check if this is a valid command
	if(is_command($COMMAND)){
		#last;
	}
	else{
		print "Invalid command. Please input a valid command. \n";
		redo LINE;
	}

	#Construct the command to print out to the user to see 
	$command = "-u " . $USR . ":" . " -H cipres-appkey:" . $APP_ID . " ";

	#Exit from the program
	if($COMMAND eq "e" || $COMMAND eq "E" || $COMMAND eq "exit"){
		exit 0;
	}
	elsif($COMMAND eq "gt" || $COMMAND eq "GT"){
		$command = $command . $URL . "tool";
		print "Listing the available tools \n";
		@ns_headers = (
			'cipres-appkey' => $APP_ID,
		);
		$REQ_TYPE = "GET";
		$url = $URL . "tool";
	}
	# This is the basic list jobs command
	elsif($COMMAND eq "lj" || $COMMAND eq "LJ"){
		$command = $command . $URL . "job/" . $USR;
		print "Listing your jobs \n";
		# A Basic HTTP Authentication example
		# Need to create the headers required for the http GET request
		@ns_headers = (
			'cipres-appkey' => $APP_ID,
		);
		$REQ_TYPE = "GET";
		# We need to build the URL we are performing the GET request from
		$url = $URL . "job/" .  $USR;
	}
	# The command is to delete a job that was submitted 
	elsif($COMMAND eq "d" || $COMMAND eq "D"){
		#Query for the file to be deleted
		print "Please provide the name of the job to be deleted\n";
		print ("eg. 'NGBW-JOB-CLUSTALW-3957CC6EBF5E448095A5666B41EDDF90'\n");
		$APPNAME = <STDIN>;
		chomp($APPNAME);
		print "User typed $APPNAME\n";

		#Create the http request 
		$command = $command . "-X DELETE " . $URL ."job/" . $USR . "/" . $APPNAME;
		print "We will delete the job: " . $APPNAME . "\n";
		@ns_headers = (
			'cipres-appkey' => $APP_ID,
		);
		# This is a GET request
		$REQ_TYPE = "DELETE";
	
		# Develop the command 
		$url = $URL . "job/" . $USR . "/" . $APPNAME;
	}
	# This is the command to submit a job
	# Prompt the user for the type of tool and the inputfile
	elsif ($COMMAND eq "s" || $COMMAND eq "S"){
		# Query for the type of tool
		print "Please provide a tool to use (ex. CLUSTALW) \n";
		$TOOL = <STDIN>;
		chomp($TOOL);
		print "User typed $TOOL \n";

		# Query for the input file
		print "Please provide an input file: \n";
		$INPUT = <STDIN>;
		chomp($INPUT);
		print "User typed $INPUT \n";
		$INPUT = "./" . $INPUT;

		#Query if they would like to provide a tree input
		print "Would you like to provide a tree file? (Y/N)?";
		$TREE = <STDIN>;
		chomp($TREE);
		print "User typed $TREE\n";
		if($TREE eq "Y" || $TREE eq "y"){
			print "Please provide the tree file below (eg. guidetree.dnd)\n";
			$TREE_FILE = <STDIN>;
			chomp($TREE_FILE);
			print "User typed $TREE_FILE\n";
		}

		#Query if user wants to have the results emailed to them
		print "Would you like the results to be emailed to you (Y/N)\n";
		$EMAIL = <STDIN>;
		chomp($EMAIL);
		print "User typed $EMAIL \n";

		#Query for job ID from user input
		print "Please provide a job ID number (eg. 110) that you will recognize \n";
		$JOB_ID = <STDIN>;
		chomp($JOB_ID);
		#Should check if this is a valid ID number
		print "User typed $JOB_ID\n";

		# Submit the job and extra files
		# if the user wishes to provide them.
		print "Submitting a job with input file: $INPUT \n";
		$command = $command . "-F tool=$TOOL ";
		$command = $command . "-F input.infile_=$INPUT ";
		if($TREE eq "Y" || $TREE eq "y"){
			$command = $command . "-F input.usetree_=$TREE_FILE";
		}
		# Does the user want an email to notify them
		if($EMAIL eq "Y" || $EMAIL eq "y"){
			$command = $command . "-F metadata.statusEmail=TRUE ";
		}
		else{
		}
		$command = $command . "-F metadata.clientJobId=$JOB_ID ";
		$command = $command . "-F vparam.runtime_=1";

		@ns_headers = (
			'Content_Type' => 'form-data',
			'cipres-appkey' => $APP_ID,
		);
		$REQ_TYPE = "POST";
		# We need to build the URL we are performing the GET request from
		$url = $URL . "job/" .  $USR;
	}
	# The command is to list the results of a submitted job
	elsif($COMMAND eq 'lr' || $COMMAND eq 'LR'){
		#Query for the application uri
		print "Please provide the name of the submitted job\n";
		print ("eg. 'NGBW-JOB-CLUSTALW-3957CC6EBF5E448095A5666B41EDDF90'\n");
		$APPNAME = <STDIN>;
		chomp($APPNAME);
		print "User typed $APPNAME\n";

		#Create the http request
		$command = $command . $URL ."job/" . $USR . "/" . $APPNAME . "/output";
		print "Listing the job results \n";
		@ns_headers = (
			'cipres-appkey' => $APP_ID,
		);
		$url = $URL . "job/" .  $USR . "/" . $APPNAME . "/output";
		#This is a GET request
		$REQ_TYPE = "GET"; 
	}
	# The command is to download results for a specific submitted job
	elsif($COMMAND eq 'dr' || $COMMAND eq 'DR'){
		#Query for the outputfile name 
		print "Please provide the output file name \n";
		$RESULTS_FILE = <STDIN>;
		chomp($RESULTS_FILE);
		print "User typed $RESULTS_FILE\n";

		#Query for the job name
		print "Please provide the job download URI \n";
		print "Eg NGBW-JOB-CLUSTALW-E999C970C4754A4CB3E44CF87EF30DF0/output/4990 \n";
		$JOB_NAME = <STDIN>;
		chomp($JOB_NAME);
		print "User typed $JOB_NAME\n";

		#Create the http request to download the specific 
		# job results 
		$command = $command . "job/" . $USR . "/" . $JOB_NAME;
		@ns_headers = (
			'cipres-appkey' => $APP_ID,
		);
		$url = $URL . "job/" .  $USR  . "/" . $JOB_NAME;

		#This is a GET request
		$REQ_TYPE = "GET";
	}
	print $command . "\n";

	# Combine all the info obtained from the user and 
	# sent the POST/GET/DELETE HTTP request accordingly. 
	if($REQ_TYPE eq "DELETE"){
		print "\n";
		# Send the DELETE HTTP request
		my $response = $browser->delete($url, @ns_headers);

		# Check if there was an authorization error and 
		# request the credentials again.
		if(($response->code eq "401")){
		 	print "\nPlease input the correct credentials \n";

			# Query for username 
			print "Please provide your username: \n";
			$USR =  <STDIN>;
			chomp ($USR);

			# Query for password
			print "Please provide your password: \n";
			$PASSWORD = <STDIN>;
			chomp ($PASSWORD);

			# Apply the new provided credentials
			$browser->credentials(
				$SERVER . ':' . $PORT,
				$REALM,
				$USR => $PASSWORD
			);
		 }
		elsif($response->code eq "404"){
			print "Error: ", $response->header('WWW-Authenticate') || 
			 	'Error accessing',
			# ('WWW-Authenticate' is the realm-name)
			 "\n ", $response->status_line, "\n at $url\n Aborting.\n";
			 print "Something went wrong with the provided URL or command. \n",
			 "Please provide a valid one \n";
			 die();
		}
		# If it is a different error other than an unauthorized error, 
		# print the message and request for a new command.
		elsif(!$response->is_success){
			print "Error: ", $response->header('WWW-Authenticate') || 
			 	'Error accessing',
			# ('WWW-Authenticate' is the realm-name)
			 "\n ", $response->status_line, "\n at $url\n Aborting.\n";
			 print "Please try the command again \n\n";		 	
		}
		# If there are no errors, print out the response normally.
		else {
			print $response->content . "\n";
			print "The job has been deleted successfully \n\n";
		}
	}
	# The HTTP request is a GET request
	elsif($REQ_TYPE eq "GET"){
 		my $response = $browser->get($url, @ns_headers);
		
		# Check if there was an authorization error and 
		# request the credentials again.
		 if(($response->code eq "401")){
		 	print "\nPlease input the correct credentials \n";

			# Query for username 
			print "Please provide your username: \n";
			$USR =  <STDIN>;
			chomp ($USR);

			# Query for password
			print "Please provide your password: \n";
			$PASSWORD = <STDIN>;
			chomp ($PASSWORD);

			# Apply the new provided credentials
			$browser->credentials(
				$SERVER . ':' . $PORT,
				$REALM,
				$USR => $PASSWORD
			);
		 }
		elsif($response->code eq "404"){
			print "Error: ", $response->header('WWW-Authenticate') || 
			 	'Error accessing',
			# ('WWW-Authenticate' is the realm-name)
			 "\n ", $response->status_line, "\n at $url\n Aborting.\n";
			 print "Something went wrong with the provided URL or command. \n",
			 "Please provide a valid one \n";
			 die();
		}
		# If it is a different error other than an unauthorized error, 
		# print the message and request for a new command.
		elsif(!$response->is_success){
			print "Error: ", $response->header('WWW-Authenticate') || 
			 	'Error accessing',
			# ('WWW-Authenticate' is the realm-name)
			 "\n ", $response->status_line, "\n at $url\n Aborting.\n";
			 print "Please try the command again \n\n";		 	
		}
		# If there are no errors, print out the response normally.
		else{
			# Print out the contents of the page that was gotten through the GET request
			if($COMMAND eq "GT" || $COMMAND eq "gt"){
				open(outfile, ">./tools.xml");
				print outfile $response->content . "\n";
				close(outfile);
				print "Please see the tools.xml file in the current directory.\n\n";
	 		}
	 		elsif($COMMAND eq "DR" || $COMMAND eq "dr"){
				#print $response->content . "\n";
	 			open(outfile, ">./$RESULTS_FILE");
	 			print outfile $response->content . "\n";
	 			close(outfile);
	 			print "Please see the file '$RESULTS_FILE' in the current directory. \n\n";
	 		}
	 		# For any command other than "gt" and "dr"
			else{
				print $response->content . "\n";
			}
		}
	}
	# If the HTTP request type is a POST
	elsif($REQ_TYPE eq "POST"){
		my $response = "";
		#Check if the user wanted to receive an email when the job is finished
		if($EMAIL eq "Y" || $EMAIL eq "y"){
			print "User wants their results emailed \n";
			my $EMAIL_BOOL = "true ";
			#Check if the user provided a tree input file
			if($TREE eq "Y" || $TREE eq "y"){
				$response = $browser->post($url, [
					'tool' => $TOOL,
					'input.infile_' => [$INPUT],
					'input.usetree_'=> [$TREE_FILE],
					'metadata.statusEmail' => "true",
					'metadata.clientJobId' => $JOB_ID,
					'vparam.runtime_' => "1",
					],
				@ns_headers);
			}
			# User did not provide a tree file
			else{
				$response = $browser->post($url, [
					'tool' => $TOOL,
					'input.infile_' => [$INPUT],
					'metadata.statusEmail' => "true",
					'metadata.clientJobId' => $JOB_ID,
					'vparam.runtime_' => "1",
					],
				@ns_headers);
			}
		}
		#User did not want to receive an email when job is finished
		else{
			# Check if user provided tree input file
			if($TREE eq "Y" || $TREE eq "y"){
				$response = $browser->post($url, [
					'tool' => $TOOL,
					'input.infile_' => [$INPUT],
					'input.usetree_'=> [$TREE_FILE],
					'metadata.clientJobId' => $JOB_ID,
					'vparam.runtime_' => "1",
				],
				@ns_headers);
			}
			#User did not provide a tree input file
			else{
				$response = $browser->post($url, [
					'tool' => $TOOL,
					'input.infile_' => [$INPUT],
					'metadata.clientJobId' => $JOB_ID,
					'vparam.runtime_' => "1",
				],
				@ns_headers);
			}
			print "User does not want their results emailed \n";
		}

		# Check if there was an authorization error and 
		# request the credentials again.
		if(($response->code eq "401")){
		 	print "\nPlease input the correct credentials \n";

			# Query for username 
			print "Please provide your username: \n";
			$USR =  <STDIN>;
			chomp ($USR);

			# Query for password
			print "Please provide your password: \n";
			$PASSWORD = <STDIN>;
			chomp ($PASSWORD);

			# Apply the new provided credentials
			$browser->credentials(
				$SERVER . ':' . $PORT,
				$REALM,
				$USR => $PASSWORD
			);
		}
		elsif($response->code eq "404"){
			print "Error: ", $response->header('WWW-Authenticate') || 
			 	'Error accessing',
			# ('WWW-Authenticate' is the realm-name)
			 "\n ", $response->status_line, "\n at $url\n Aborting.\n";
			 print "Something went wrong with the provided URL or command. \n",
			 "Please provide a valid one \n";
			 die();
		}
		# If it is a different error other than an unauthorized error, 
		# print the message and request for a new command.
		elsif(!$response->is_success){
			print "Error: ", $response->header('WWW-Authenticate') || 
			 	'Error accessing',
			# ('WWW-Authenticate' is the realm-name)
			 "\n ", $response->status_line, "\n at $url\n Aborting.\n";
			 print "Please try the command again \n\n";		 	
		}
		# If there are no errors, print out the response normally.
		else {
			print $response->content . "\n";
		}
	}
	else {
		print "Something went wrong \n";
		exit 0;
	}

	#Prompt for user input again
	print "What would you like to do? Valid commands are: \n";
	print "List Jobs (LJ); Submit Job (S); Delete Job (D); List Results (LR); \n";
	print "Download Results (DR); Get Tools (GT); Exit (E) \n";
	redo LINE;
}
#--------------------------------------------------------------------
#This subroutine will determine if the string is a valid command
sub is_command{
	return($_[0] eq "lj" || $_[0] eq "LJ" || 
	$_[0] eq "s" || $_[0] eq "S" || 
	$_[0] eq "d" || $_[0] eq "D" ||
	$_[0] eq "lr" || $_[0] eq "LR" ||
	$_[0] eq  "e" || $_[0] eq "E" || $_[0] eq "exit" ||
	$_[0] eq "gt" || $_[0] eq "GT" ||
	$_[0] eq "dr" || $_[0] eq "DR");
}