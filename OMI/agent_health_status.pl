#!/usr/bin/perl
#Use this script to check the health status of all OA nodes. This script runs opcagt against all nodes to check the agent health status
 
use strict;
use warnings;
my $omi_user='admin';
my $omi_pass='########';
my $omi_fqdn='########';
my $omi_port=443;
my @node_list = `/opt/HP/BSM/opr/bin/opr-agt -username $omi_user -password $omi_pass -query_name All_CIs_with_OM_Agents -list_agent_nodenames -u https://$omi_fqdn:$omi_port/opr-config-server`;
foreach my $node (@node_list) {
        eval {
                local $SIG{ALRM} = sub {
                        print "$node: Timed out\n";
                        die
                };
                alarm(20);
                chomp($node);
                $node =~ s/^\s+|\s+$//g;
                my $command = `/opt/OV/bin/ovdeploy -cmd \"opcagt\" -node $node -ovrg server \| grep \"Agent Health Status\"`;
                if ($command eq "") {
                        print "$node: Error\n";
                }
                else {
                        my ($grepped,$time) = split (",",$command);
                        my ($status_text,$status) = split (":",$grepped);
                        print "$node:$status\n";
                }
                alarm(0);
        };
}
