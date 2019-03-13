#!/usr/bin/perl -w
#Use this script to check if POST request to BVD is working or not
 
use strict;
#use LWP::Simple;
use LWP::UserAgent;
 
my $ua = LWP::UserAgent->new;
my $test_bvd = "
{
        \"BVD\": \"Test\",
        \"Status\": \"Working\"
}
";
print "\n$test_bvd\n";
#Make changes to BVD details accordingly
my $server_endpoint = 'http://<BVD FQDN>:<Receiver Port>/api/submit/<BVD API>/dims/BVD,Status/tags/global';
 
my $req = HTTP::Request->new(POST => $server_endpoint);
$req->header('content-type' => 'application/json');
my $post_data=$test_bvd;
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
