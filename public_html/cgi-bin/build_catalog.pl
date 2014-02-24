#!/usr/bin/perl

use strict;
use warnings;
use Config::Properties;
use XML::Writer;
use CGI qw(:standard);

print header('text/xml');
my ($prop_file, $properties);

#load hash for Names of Sport
$prop_file="/home/ccichon/rtss-code/properties/sport.properties";
open PROPS, "< $prop_file" or die "unable to open properties $prop_file\n";
$properties= new Config::Properties();
$properties->load(*PROPS);
my %sport_keys=$properties->properties;
close PROPS;

#load hash for Names of Level
$prop_file="/home/ccichon/rtss-code/properties/level.properties";
open PROPS, "< $prop_file" or die "unable to open properties $prop_file\n";
$properties= new Config::Properties();
$properties->load(*PROPS);
my %level_keys=$properties->properties;
close PROPS;

#load hash for Names of Locations
$prop_file="/home/ccichon/rtss-code/properties/location.properties";
open PROPS, "< $prop_file" or die "unable to open properties $prop_file\n";
$properties= new Config::Properties();
$properties->load(*PROPS);
my %location_keys=$properties->properties;
close PROPS;

#load hash for Names of Games
$prop_file="/home/ccichon/rtss-code/properties/game.properties";
open PROPS, "< $prop_file" or die "unable to open $prop_file\n";
$properties= new Config::Properties();
$properties->load(*PROPS);
my %games=$properties->properties;
close PROPS;


#my $output = new IO::File (">catalog.xml");
my $output = '';   # if outputing directly in CGI output
my $base_dir = "/home/ccichon/rtss-code/catalog";
my $writer = new XML::Writer (OUTPUT => $output);

$writer->xmlDecl ('UTF-8');
$writer->startTag ('CATALOG');


opendir (my $dh_sport, $base_dir) || die "Cannot open $base_dir $!\n";
while (defined (my $dir_sport = readdir $dh_sport)) {
	next unless -d "$base_dir/$dir_sport";
	next if $dir_sport =~ /^\.\.?+$/;
	my $spt_nme = $sport_keys{$dir_sport};
	$writer->startTag ('SPORT', 'SPT_ID' => "$dir_sport", 'SPT_NME' => "$spt_nme");

	opendir (my $dh_level, "$base_dir/$dir_sport") || die "Cannot open $dir_sport $!\n";
	while (defined (my $dir_level = readdir $dh_level)) {
		next unless -d "$base_dir/$dir_sport/$dir_level";
		next if $dir_level =~ /^\.\.?+$/;
		my $lev_name = $level_keys{$dir_level};
		$writer->startTag ('LEVEL', 'LEV_ID' => "$dir_level", 'LEV_NAME' => "$lev_name");

		opendir (my $dh_loc, "$base_dir/$dir_sport/$dir_level") || die "Cannot open $dir_level $!\n";
		while (defined (my $dir_loc = readdir $dh_loc)) {
			next unless -d "$base_dir/$dir_sport/$dir_level/$dir_loc";
			next if $dir_loc =~ /^\.\.?+/;
			my $loc_nme = $location_keys{$dir_loc};
			$writer->startTag ('LOCATION', 'LOC_ID' => "$dir_loc", 'LOC_NAME', "$loc_nme");

			opendir (my $dh_gmd, "$base_dir/$dir_sport/$dir_level/$dir_loc") || die "Cannot open $dir_loc $!\n";
			while (defined (my $dir_gmd = readdir $dh_gmd)) {
				next unless -d "$base_dir/$dir_sport/$dir_level/$dir_loc/$dir_gmd";
				next if $dir_gmd =~ /^\.\.?+/;
				my $gmd_name = $games{$dir_gmd};
				$writer->startTag ('GAME', 'GMD_ID' => "$dir_gmd", 'GMD_NAME' => "$gmd_name");

				opendir (my $dh_files, "$base_dir/$dir_sport/$dir_level/$dir_loc/$dir_gmd") || die " Cannot open $dir_gmd $!\n";
				while (defined (my $file = readdir $dh_files)) {
					next if $file =~ /^\.\.?+/;
					next if $file eq "$dir_gmd.xml";
					if (-f $file) {
						$file =~ s/.xml$//;
						#$writer->emptyTag ('STAT_FILE', 'SF' => "$file");
					}
				}
				$writer->endTag ('GAME');
			}
			$writer->endTag('LOCATION');
		}	
		$writer->endTag('LEVEL');
	}
	$writer->endTag('SPORT');
}
$writer->endTag('CATALOG');
$writer->end();

