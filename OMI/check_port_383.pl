#!/usr/bin/perl
#Use this script to find whether port 383 is opened between OMI/OBR to managed nodes. This is helpful in environments where telnet/netcat command is not installed
#
#Usage Syntax: perl check_port_383.pl <host file>

use strict;
use warnings;
use IO::Socket::INET;

my $file =  $ARGV[0];

if (not defined $file) {
        die "
File name not provided

Syntax: perl $0 <node list file>
";
}
open (my $fh,'<:encoding(UTF-8)', $file);
my $port = 383;
while (<$fh>){
        chomp;
        my $host=$_;
        $host =~ s/^\s+|\s+$//g;
        my $socket = new IO::Socket::INET(
                PeerHost => $host,
                PeerPort => $port,
                Proto => 'tcp',
                Timeout => 2,
        );
        if ($socket) {
                print "$host: Connected\n";
        }
        else {
                print "$host: Failed\n";
        }
}
close $fh;
