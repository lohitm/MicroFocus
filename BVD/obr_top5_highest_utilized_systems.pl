#!/usr/bin/perl
#This script is designed to collect the top 5 higest utilized systems from OBR's vertica database SH_SM_NODE_RES and send the data to BVD. This needs to be run from vertica server with the vertica db user
#Author: Lohit Mohanta
 
use strict;
use LWP::Simple;
use LWP::UserAgent;
 
my $ua = LWP::UserAgent->new;
 
#Enter vertica details
my $db_port = 6021;
my $db_user = "dbuser";
my $db_pwd = "########";
 
#Enter BVD details
my $bvd_server = "###################";
my $bvd_receiver_port = 12224;
my $bvd_api_key = "######################";
 
my $interval = 900;
 
label:
 
my @topmem = `vsql -p $db_port -U $db_user -w $db_pwd -c "select name, ta_period, avgMemUtil from SH_SM_NODE_RES, K_CI_System where dsi_key_id_=dsi_key_id and ta_period = (select max(ta_period) from SH_SM_NODE_RES) order by avgMemUtil desc limit 5"`;
 
my @topcpu = `vsql -p $db_port -U $db_user -w $db_pwd -c "select name, ta_period, avgCPUUtil from SH_SM_NODE_RES, K_CI_System where dsi_key_id_=dsi_key_id and ta_period = (select max(ta_period) from SH_SM_NODE_RES) order by avgCPUUtil desc limit 5"`;
 
splice @topmem, 0, 2;
splice @topmem, -2;
splice @topcpu, 0, 2;
splice @topcpu, -2;
 
tr/|/,/ for @topmem;
tr/|/,/ for @topcpu;
 
my ($cpu_node1,$cpu_node2,$cpu_node3,$cpu_node4,$cpu_node5)="";
my ($mem_node1,$mem_node2,$mem_node3,$mem_node4,$mem_node5)="";
my ($time)="";
my ($cpu1,$cpu2,$cpu3,$cpu4,$cpu5)=0;
my ($mem1,$mem2,$mem3,$mem4,$mem5)=0;
 
($mem_node1,$time,$mem1) = split(",",$topmem[0]);
($mem_node2,$time,$mem2) = split(",",$topmem[1]);
($mem_node3,$time,$mem3) = split(",",$topmem[2]);
($mem_node4,$time,$mem4) = split(",",$topmem[3]);
($mem_node5,$time,$mem5) = split(",",$topmem[4]);
 
($cpu_node1,$time,$cpu1) = split(",",$topcpu[0]);
($cpu_node2,$time,$cpu2) = split(",",$topcpu[1]);
($cpu_node3,$time,$cpu3) = split(",",$topcpu[2]);
($cpu_node4,$time,$cpu4) = split(",",$topcpu[3]);
($cpu_node5,$time,$cpu5) = split(",",$topcpu[4]);
 
$cpu_node1 =~ s/^\s+|\s+$//g;
$cpu_node2 =~ s/^\s+|\s+$//g;
$cpu_node3 =~ s/^\s+|\s+$//g;
$cpu_node4 =~ s/^\s+|\s+$//g;
$cpu_node5 =~ s/^\s+|\s+$//g;
 
$mem_node1 =~ s/^\s+|\s+$//g;
$mem_node2 =~ s/^\s+|\s+$//g;
$mem_node3 =~ s/^\s+|\s+$//g;
$mem_node4 =~ s/^\s+|\s+$//g;
$mem_node5 =~ s/^\s+|\s+$//g;
 
$cpu1 =~ s/^\s+|\s+$//g;
$cpu2 =~ s/^\s+|\s+$//g;
$cpu3 =~ s/^\s+|\s+$//g;
$cpu4 =~ s/^\s+|\s+$//g;
$cpu5 =~ s/^\s+|\s+$//g;
 
$mem1 =~ s/^\s+|\s+$//g;
$mem2 =~ s/^\s+|\s+$//g;
$mem3 =~ s/^\s+|\s+$//g;
$mem4 =~ s/^\s+|\s+$//g;
$mem5 =~ s/^\s+|\s+$//g;
 
$time =~ s/^\s+|\s+$//g;
 
#Queries Top CPU and Memory Stats
print "\nStats:
Top CPU from OBR
================
$cpu_node1:$cpu1
$cpu_node2:$cpu2
$cpu_node3:$cpu3
$cpu_node4:$cpu4
$cpu_node5:$cpu5
 
Top Memory from OBR
===================
$mem_node1:$mem1
$mem_node2:$mem2
$mem_node3:$mem3
$mem_node4:$mem4
$mem_node5:$mem5
";
 
my $json_bvd_cpu_node_name = "{
        \"Server\": \"Top CPU Servers\",
        \"server1\" : \"$cpu_node1\",
        \"server2\" : \"$cpu_node2\",
        \"server3\" : \"$cpu_node3\",
        \"server4\" : \"$cpu_node4\",
        \"server5\" : \"$cpu_node5\"
}";
my $json_bvd_cpu_node_pct = "{
        \"Server\": \"Top CPU Pct\",
        \"server1\" : $cpu1,
        \"server2\" : $cpu2,
        \"server3\" : $cpu3,
        \"server4\" : $cpu4,
        \"server5\" : $cpu5
}";
my $json_bvd_mem_node_name = "{
        \"Server\": \"Top Mem Servers\",
        \"server1\" : \"$mem_node1\",
        \"server2\" : \"$mem_node2\",
        \"server3\" : \"$mem_node3\",
        \"server4\" : \"$mem_node4\",
        \"server5\" : \"$mem_node5\"
}";
my $json_bvd_mem_node_pct = "{
        \"Server\": \"Top Mem Pct\",
        \"server1\" : $mem1,
        \"server2\" : $mem2,
        \"server3\" : $mem3,
        \"server4\" : $mem4,
        \"server5\" : $mem5
}";
 
push my @json_bvd_all, "$json_bvd_cpu_node_name","$json_bvd_cpu_node_pct","$json_bvd_mem_node_name","$json_bvd_mem_node_pct";
print "\n\nFormatted stats for BVD\n=======================\n@json_bvd_all\n";
print "HTTP/HTTPS POST status to BVD\n=============================\n";
foreach my $json_bvd (@json_bvd_all) {
                my $server_endpoint = "http://$bvd_server:$bvd_receiver_port/api/submit/$bvd_api_key/dims/Server/tags/Top Utilized";
                my $req = HTTP::Request->new(POST => $server_endpoint);
 
                $req->header('content-type' => 'application/json');
                my $post_data = $json_bvd;
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
}
print "\nWaiting $interval seconds for the next poll\n";
sleep ($interval);
goto label
