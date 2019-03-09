# MicroFocus
This script can be used to send data from CSV file to BVD. The csv file must have 2 columns. The 1st column is for metric name and the second column is for value. The value column can also have a string. The script will convert the csv data to json and send to BVD.

Prerequisites
1) Perl needs to be installed on the sender machine
2) Following Perl modules need to be installed prior to running this script
    JSON
    LWP::Simple
    LWP::UserAgent
3) The receiver port on BVD server must be open for communication from sender machine<br /><br />
    


To use the script, open the script "bvd_csv_to_json.pl" and add BVD server details as below

my $bvd_server = "xxxxxxxxxxxxxxxxx"; # FQDN or IP address of BVD server<br />
my $bvd_receiver_port = "12224"; # Receiver port number of BVD server <br />
my $bvd_api_key = "xxxxxxxxxxxxxxx"; # API Key of BVD<br />
my $bvd_tag  = "BVD"; # Tag name to identify the data<br />
my $bvd_dim = "BVD"; # Dimension. This is the name associated with the value provided.<br />
my $bvd_dim_value = "value";<br /><br /><br />



Syntax: perl bvd_csv_to_json.pl \<CSV File\>
