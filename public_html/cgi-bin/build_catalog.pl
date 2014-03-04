#!/usr/bin/perl

use strict;
use warnings;
use Config::Properties;
use XML::Writer;
use CGI qw(:standard);

print header('text/xml');
my ($prop_file, $properties);

#load hash for Names of Sport
$prop_file="/home/realtin5/properties/sport.properties";
open PROPS, "< $prop_file" or die "unable to open properties $prop_file\n";
$properties= new Config::Properties();
$properties->load(*PROPS);
my %sport_keys=$properties->properties;
close PROPS;

#load hash for Names of Level
$prop_file="/home/realtin5/properties/level.properties";
open PROPS, "< $prop_file" or die "unable to open properties $prop_file\n";
$properties= new Config::Properties();
$properties->load(*PROPS);
my %level_keys=$properties->properties;
close PROPS;


#load hash for Names of League
$prop_file="/home/realtin5/properties/league.properties";
open PROPS, "< $prop_file" or die "unable to open properties $prop_file\n";
$properties= new Config::Properties();
$properties->load(*PROPS);
my %league_keys=$properties->properties;
close PROPS;


#load hash for Names of Seasons 
$prop_file="/home/realtin5/properties/season.properties";
open PROPS, "< $prop_file" or die "unable to open properties $prop_file\n";
$properties= new Config::Properties();
$properties->load(*PROPS);
my %season_keys=$properties->properties;
close PROPS;

#load hash for Names of Games
$prop_file="/home/realtin5/properties/game.properties";
open PROPS, "< $prop_file" or die "unable to open $prop_file\n";
$properties= new Config::Properties();
$properties->load(*PROPS);
my %games=$properties->properties;
close PROPS;


#my $output = new IO::File (">catalog.xml");
my $output = '';   # if outputing directly in CGI output
my $base_dir = "/home/realtin5/catalog";
my $writer = new XML::Writer (OUTPUT => $output);

$writer->xmlDecl ('UTF-8');
$writer->startTag ('CATALOG');


opendir (my $dh_sport, $base_dir) || die "Cannot open $base_dir $!\n";
while (defined (my $dir_sport = readdir $dh_sport)) {
	next unless -d "$base_dir/$dir_sport";
	next if $dir_sport =~ /^\.\.?+$/;
	my $spt_nme = $sport_keys{$dir_sport};
	$writer->startTag ('SPORT', 'SPRT_ID' => "$dir_sport", 'SPRT_NME' => "$spt_nme");

	opendir (my $dh_level, "$base_dir/$dir_sport") || die "Cannot open $dir_sport $!\n";
	while (defined (my $dir_level = readdir $dh_level)) {
		next unless -d "$base_dir/$dir_sport/$dir_level";
		next if $dir_level =~ /^\.\.?+$/;
		my $lev_name = $level_keys{$dir_level};
		$writer->startTag ('LEVEL', 'SHR_ID' => "$dir_level", 'NME' => "$lev_name");

                opendir (my $dh_league, "$base_dir/$dir_sport/$dir_level") || die "Cannot open $dir_level $!\n";
                while (defined (my $dir_league = readdir $dh_league)) {
                        next unless -d "$base_dir/$dir_sport/$dir_level/$dir_league";
                        next if $dir_league =~ /^\.\.?+/;
                        my $league_nme = $league_keys{$dir_league};
 			$writer->startTag ('LEAGUE', 'SHR_ID' => "$dir_league", 'NME', "$league_nme");

			opendir (my $dh_sesn, "$base_dir/$dir_sport/$dir_level/$dir_league") || die "Cannot open $dir_league $!\n";
			while (defined (my $dir_sesn = readdir $dh_sesn)) {
				next unless -d "$base_dir/$dir_sport/$dir_level/$dir_league/$dir_sesn";
				next if $dir_sesn =~ /^\.\.?+/;
				my $sesn_nme = $season_keys{$dir_sesn};
				$writer->startTag ('SEASON', 'SHR_ID' => "$dir_sesn", 'NME', "$sesn_nme");

				opendir (my $dh_gmd, "$base_dir/$dir_sport/$dir_level/$dir_league/$dir_sesn") || die "Cannot open $dir_sesn$!\n";
				while (defined (my $game = readdir $dh_gmd)) {
					next unless $game =~ /xml$/;
					#next if $game =~ /_SF_/;
					open my $fh, "<", "$base_dir/$dir_sport/$dir_level/$dir_league/$dir_sesn/$game" or die "Couldn't read '$game': $!\n";
					my @line = grep { /GAME CLT_ID/ } <$fh>;
					my ($gar1, $clt_id, $gar2, $gar3, $gar4, $gar5, $gar6, $gar7, $gar8, $nme, $gar10) = split /\"/, $line[0];
					$writer->startTag ('GAME', 'SHR_ID' => "$clt_id", 'NME' => "$nme", 'GME_FILE' => "$game");
					close $fh;

					#next unless -d "$base_dir/$dir_sport/$dir_level/$dir_league/$dir_sesn/$dir_gmd";
					#next if $dir_gmd =~ /^\.\.?+/;
					#my $gmd_name = $games{$dir_gmd};
					#$writer->startTag ('GAME', 'SHR_ID' => "$dir_gmd", 'NME' => "$gmd_name");

					#opendir (my $dh_files, "$base_dir/$dir_sport/$dir_level/$dir_league/$dir_sesn/$dir_gmd") || die " Cannot open $dir_gmd $!\n";
					#while (defined (my $file = readdir $dh_files)) {
					#	next if $file =~ /^\.\.?+/;
					#	next if $file eq "$dir_gmd.xml";
					#	if (-f $file) {
					#		$file =~ s/.xml$//;
					#		$writer->emptyTag ('STAT_FILE', 'SF' => "$file");
					#	}
					#}
					$writer->endTag ('GAME');
 				}
                	        $writer->endTag('SEASON');

			}
			$writer->endTag('LEAGUE');
		}	
		$writer->endTag('LEVEL');
	}
	$writer->endTag('SPORT');
}
$writer->endTag('CATALOG');
$writer->end();

