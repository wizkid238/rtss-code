#!/usr/bin/perl

use CGI;
use Config::Properties;

my $prop_file="/home/realtin5/properties/key.properties";

open PROPS, "< $prop_file"
        or print "unable to open properties file\n";

my $properties = new Config::Properties();
$properties->load(*PROPS);
my %redirect_keys=$properties->properties;
close PROPS;

# First we need to get the parms and put them in a hash so we can 
# cycle through them

my $p = new CGI;
my %parms = $p->Vars;
my ($redirect, $parm_list);
$parm_list = "";

# For each parm (key pair) that we find, cycle through
# If the key in the key value pair = key, then that's the file we want to load
# else tag the new direct with a 1 to 1 comparison.
foreach my $key (keys(%parms)) {
	#print "$key\n";
	#print "$parm_list\n";

	if ($key eq "key") {
		$redirect = $redirect_keys{$parms{$key}};
	} else {
		$parm_list = "&$key=$parms{$key}" . $parm_list;
	}
}

$parm_list =~ s/^&/\?/;

$url="http://www.realtimesportstats.com/$redirect$parm_list";
#print "$url\n";
my $redirect_query=new CGI;
print $redirect_query->redirect($url);

