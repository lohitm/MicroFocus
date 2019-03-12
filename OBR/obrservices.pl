#!/usr/bin/perl
#This script can be used to stop/start/restart all OBR services. It has been tested on RHEL 7.3
#Author: Lohit Mohanta

use strict;
#use warnings;

my @hpe = ("HPE_PMDB_Platform_Collection","HPE_PMDB_Platform_Orchestration","HPE_PMDB_Platform_Administrator","HPE_PMDB_Platform_PostgreSQL","HPE_PMDB_Platform_JobManager","HPE_PMDB_Platform_TaskManager","HPE_PMDB_Platform_DB_Logger","HPE_PMDB_Platform_IM","HPE_PMDB_Platform_NRT_ETL","HPE_PMDB_Platform_IA","TrendTimer");

label:

print "

1. Stop all services
2. Start all services
3. Restart all services
4. Check Status
5. Exit

Enter Choice: ";

my $selection = <STDIN>;
my $col;
sub status {
	print "\nPrinting service status:\n\n";
	print "----------------------------------------------------\n";
	foreach (@hpe){
		chomp;
		my $status = `systemctl is-active $_`;
		$status =~ s/^\s+|\s+$//g;
		$status eq "active" ? $status = "$status  " : $status = $status;
		my $service = $_;
		$service =~ s/^\s+|\s+$//g;
		my $len = length($service);
		if ($len <= 10) {
			$service = "$service\t\t\t";
		}
		elsif (($len > 10) && ($len <=20)) {
			$service = "$service\t\t";
		}
		elsif (($len > 20) && ($len <=24)){
			$service = "$service\t\t";
		}
                elsif (($len > 24) && ($len <=30)){
                        $service = "$service\t";
                }
		print "| $service\t| $status |\n";
		print "----------------------------------------------------\n";
	}
	print "\n";
}

sub stop {
	print "\nStopping services:\n\n";
	foreach (@hpe) {
		chomp;
		print "Stopping $_\n";	
		my $stop = `systemctl stop $_`;
	}
}

sub start {
        print "\nStarting services:\n\n";
        foreach (@hpe) {
                chomp;
                print "Starting $_\n";
                my $stop = `systemctl start $_`;
        }
}

if ($selection == 1) {
	stop();
	status();
}
elsif ($selection == 2) {
	start();
	status();
}
elsif ($selection == 3) {
	stop();
	start();
        status();
}

elsif ($selection == 4) {
	status();
}
elsif ($selection == 5) {
	exit;
}
else {
	print "\nWrong Choice!!!\n";
	goto label;
}

