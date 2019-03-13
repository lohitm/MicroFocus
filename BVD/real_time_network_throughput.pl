#!/usr/bin/perl –w
#Send realtime network throughput data to BVD for a single interface
#This is for for SNMP V3 devices only
#Before using this script ensure snmpwalk is working for the particular interface. You may have to install net-snmp tools before executing this script
#Upon successfull execution the script will send realtime throughput data to BVD for the selected interface for the interval specified
#Author: Lohit Mohanta
 
use strict;
use LWP::Simple;
use POSIX 'strftime';
use LWP::UserAgent;
 
my $ua = LWP::UserAgent->new;
my $snmpstring_sha = 'SNMPSTRING'; #Replace with  snmp SHA string here
my $snmpstring_aes = 'SNMPSTRING'; #Replace with  snmp AES string here
my $snmpstring_v2 = ''; #Community string if SNMP V2
my $snmp_user = 'USER'; #Replace with SNMP user
my $snmp_version="V3"; #Replace with SNMP version. Make sure it's in uppercase
my $value1;
my $value2;
my $delta;
my $delta_Mbps;
my $n = 10; #Interval between 2 consecutive polls
my $i = 0;
my $network_node = '<network node>'; #Replace with network node
my $null = "\"Latency\"";
my $snmpwalk;
open (STDERR, ">error.log");
sub snmpresults {
                my ($ip, $ifName) = (@_);
                if ($snmp_version eq "V2"){
                                $snmpwalk = `snmpwalk -c \"$snmpstring_v2\" -v2c $ip $ifName`;
                }
                elsif ($snmp_version eq "V3") {                
                                $snmpwalk = `snmpwalk -v3 -l authPriv -u $snmp_user -a SHA -A $snmpstring_sha -x AES128 -X $snmpstring_aes $ip $ifName`;
                }
                else {
                                print "Incorrect snmp version\n";
                }
                $snmpwalk =~ s/^\s+|\s+$//g;
                my ($metric,$counter)=split("=",$snmpwalk);   
                $counter =~ s/^\s+|\s+$//g;
                my ($string,$value)=split(":",$counter);
                $value =~ s/^\s+|\s+$//g;
                return $value;
}
sub Mbps {
                my ($poll1, $poll2) = (@_);
                my $delta = $poll2 - $poll1;
                my $delta_bits = $delta*8;
                my $delta_Mb =  $delta_bits/1000/1000;
                my $delta_Mbps = $delta_Mb/$n;
                $delta_Mbps = sprintf("%.2f", $delta_Mbps);
                return $delta_Mbps;
}
label:
 
my $interface_in1=0;
my $interface_out1=0;
 
my $interface_in2=0;
my $interface_out2=0;
 
#Replace  the ifOctets variable of the interface accordingly
$interface_in1 =  snmpresults("$network_node","ifInOctets.1");
$interface_out1 =  snmpresults("$network_node","ifOutOctets.1");
 
sleep($n);
 
#Replace  the ifOctets variable of the interface accordingly
$interface_in2 =  snmpresults("$network_node","ifInOctets.1");
$interface_out2 =  snmpresults("$network_node","ifOutOctets.1");
 
my $interface_inMbps = Mbps($interface_in1,$interface_in2);
$interface_inMbps < 0 ? $interface_inMbps = $null : $interface_inMbps = $interface_inMbps;
my $interface_outMbps = Mbps($interface_out1,$interface_out2);
$interface_outMbps < 0 ? $interface_outMbps = $null : $interface_outMbps = $interface_outMbps;
my $interface_totMbps = $interface_inMbps + $interface_outMbps;
 
my $throughput_bvd_json = "
{
                \"Interface\": \"Interface\",
                \"Interface In\": $interface_inMbps,
                \"Interface Out\": $interface_outMbps,
                \"Intereface Tot\": $interface_totMbps
}
";
print "$throughput_bvd_json\n";
my $server_endpoint = 'http://<BVD server>:<BVD receiver port>/api/submit/<BVD API>/dims/Interface/tags/Network';
my $req = HTTP::Request->new(POST => $server_endpoint);
$req->header('content-type' => 'application/json');
my $post_data = $throughput_bvd_json;
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
print "Waiting $n seconds\n";
goto label;
