#!/usr/bin/perl

use strict;
use warnings;
use Config::Properties;
use XML::Writer;
use IO::File;

my $output = new IO::File (">catalog.xml");
my $base_dir = "/home/realtin5/catalog";
my $writer = new XML::Writer (OUTPUT => $output);

$writer->xmlDecl ('UTF-8');
$writer->startTag ('CATALOG');

opendir (my $dh_sport, $base_dir) || die "Cannot open $base_dir $!\n";
while (readdir $dh_sport) {
	my $dir_sport = $_;
	if (-d $dir_sport) {
		my ($spt_id, $spt_nme) = split ('-', $dir_sport);
		$writer->startTag ('SPORT', 'SPT_ID' => "'$spt_id'", 'SPT_NME' => "'$spt_nme'");
		opendir (my $dh_level, $dir_sport) || die "Cannot open $dir_sport $!\n";
		while (readdir $dh_level) {
			my $dir_level = $_;
			if (-d $dir_level) {
				my ($lev_id, $lev_name) = split ('-', $dir_level);
				$writer->startTag ('LEVEL', 'LEV_ID' => "'$lev_id'", 'LEV_NAME' => "'$lev_name'");
				opendir (my $dh_loc, $dir_level) || die "Cannot open $dir_level $!\n";
				while (readdir $dh_loc) {
					my $dir_loc = $_;
					if (-d $dir_loc) {
						my ($loc_id, $loc_nme) = split ('-', $dir_loc);
						$writer->startTag ('LOCATION', 'LOC_ID' => '32', 'LOC_NAME', 'SOCHI');
						opendir (my $dh_gmd, $dir_loc) || die "Cannot open $dir_loc $!\n";
						while (readdir $dh_gmd) {
							my $dir_gmd = $_;
							if (-d $dir_gmd) {
								my ($gmd_id, $gmd_name) = split ('-', $dir_gmd);
								$writer->startTag ('GAME', 'GMD_ID' => "'$gmd_id'", 'GMD_NAME' => "'$gmd_name'");
								opendir (my $dh_files, $dir_gmd) || die " Cannot open $dir_gmd $!\n";
								while (readdir $dh_files) {
									my $file = $_;
									next if $file eq "$dir_gmd.xml";
									if (-f $file) {
										$writer->emptyTag ('STAT_FILE', 'SF' => "'$file'");
									}
								}
								$writer->endTag ('GAME');
							}
						}
						$writer->endTag('LOCATION');
					}
				}	
				$writer->endTag('LEVEL');
			}
		}
		$writer->endTag('SPORT');
	}
}
$writer->endTag('CATALOG');
$writer->end();
$output->close();

