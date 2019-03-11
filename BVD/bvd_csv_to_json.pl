#!/usr/bin/perl
#This script can be used to convert csv data to json format and send to Micro Focus BVD
#Refer README/bvd_csv_to_json_readme.md for more instructions
#Author: Lohit Mohanta

use strict;
use LWP::Simple;
use JSON;
use LWP::UserAgent;
my $ua = LWP::UserAgent->new;

#Enter BVD details
my $bvd_server = "xxxxxxxxxxxxxxxxx"; 
my $bvd_receiver_port = "12224";
my $bvd_api_key = "xxxxxxxxxxxxxxx";
my $input_file = $ARGV[0];
my $bvd_tag  = "Test";
my $bvd_dim = "BVD";
my $bvd_dim_value = "value";
my $interval = 900;
my $script = $0;

if ((length $bvd_server == 0) || (length $bvd_receiver_port == 0) || (length $bvd_api_key == 0)) {
	die "BVD details not provided\n";
}
if (not defined $input_file) {
       die "Syntax: perl $script <CSV File>\n";
}
if (! -e $input_file) {
        die "$input_file doesn't exist.\n";
} 
open(my $if, '<:encoding(UTF-8)', $input_file);
my @json = <$if>;
@json = grep /\S/, @json;
unshift @json, "$bvd_dim,$bvd_dim_value";
my @json_post;
foreach my $unit (@json) {
        chomp ($unit);
        my ($metric,$value) = split (",",$unit);
	push @json_post, "\"$metric\":\"$value\"";
}
my $json_post_length = @json_post;
my $i = 0;
while ($i < $json_post_length-1) {
	chomp($json_post[$i]);
	$json_post[$i] = "$json_post[$i],";
	$i++;
}	
unshift @json_post, "{";
push @json_post, "}";
my $json_scalar = join( '' , @json_post ) ;
print "\nSending the following JSON data to $bvd_server:\n$json_scalar\n"; 
my $server_endpoint = "http://$bvd_server:$bvd_receiver_port/api/submit/$bvd_api_key/dims/$bvd_dim/tags/$bvd_tag";
print "\nBVD Receiver URL: $server_endpoint\n";

my $req = HTTP::Request->new(POST => $server_endpoint);
 
$req->header('content-type' => 'application/json');
my $post_data = $json_scalar;
$req->content($post_data);
my $resp = $ua->request($req);
if  ($resp->is_success) {
    my $message = $resp->decoded_content;
    print "Metrics: $message\n";
}
else {
    print "HTTP POST error code: ", $resp->code, "\n";
    print "HTTP POST error message: ", $resp->message, "\n";
}
