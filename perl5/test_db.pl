#!/usr/bin/perl

use strict;
use warnings;
use DBI;
use Config::Properties;

my $prop_file="$ENV{HOME}/properties/db.properties";

open PROPS, "< $prop_file"
	or print "unable to open properties file\n";

my $properties = new Config::Properties();
$properties->load(*PROPS);
my %props=$properties->properties;
close PROPS;

############### Start database connection stuff #######################
my $dbh = DBI->connect("dbi:mysql:$props{'dbname'}",
				 "$props{'db_user'}",
				 "$props{'db_pass'}"
		) or die "Cannot connect to the database: $!\n";
############### End database connection stuff ##########################

print "Connection Successful.\n";
$dbh->disconnect;

