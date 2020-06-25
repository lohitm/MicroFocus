#Sample Script to connect to MSSQL database from BVD server. This script is designed to get count related results in to BVD
#Ensure ODBC connection is created before using this script

use strict;
use warnings;
use DBI;  
use Data::Dump;
use MIME::Base64;
use JSON;
use REST::Client;
use LWP::UserAgent;
           
my $user = ''; # DB user                                     
my $pwd  = ''; # DB Password                                 

my $dbh = DBI->connect("dbi:ODBC:<DSN Name>",$user,$pwd); # Use the System DSN. Here it is AMDSN

if (defined($dbh)) {
    print "Connected\n";
}
else {
    print "Error connecting to database: Error $DBI::err - $DBI::errstr\n";
}
my $tag = 'Webapps';

#Replace data and queries accordingly
my %client_hash = (
	"data1" => 'query1',
	"data2" => 'query2',
	"data3" => 'query3'
);

my %json_post;
$json_post{source} = "webapps";
$json_post{metric} = "count";

my @webapps = keys %client_hash;

foreach my $app (@webapps) {
	my $query=$client_hash{$app};
	my $exe = $dbh->prepare("$query") or die("cannot prepare query");  
	$exe->execute() or die("cannot execute");  

	while (my $res = $exe->fetchrow_hashref) {
#  		dd $res;
		my $count=$res->{Count};
		$count =~ s/\D//g;
		print "$app:$count\n";
		$json_post{$app} = $count;
	}
}
$dbh->disconnect;

my $json_scalar = encode_json(\%json_post);
print "\n$json_scalar\n";

my $ua = LWP::UserAgent->new;
my $server_endpoint = 'http://<BVD Server>:12224/api/submit/<BVD API>/dims/source,metric/tags/$tag';
my $req = HTTP::Request->new(POST => $server_endpoint);

$req->header('content-type' => 'application/json');
my $post_data=$json_scalar;
$req->content($post_data);
my $resp = $ua->request($req);
if ($resp->is_success) {
    my $message = $resp->decoded_content;
    print "Metrics: $message\n";
}
else {
    print "HTTP POST error code: ", $resp->code, "\n";
    print "HTTP POST error message: ", $resp->message, "\n";
}




