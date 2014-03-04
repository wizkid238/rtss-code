#!/usr/bin/perl

use strict;
use warnings;
use CGI qw(:standard);

my $q = CGI->new();
my $sport = $q->param('sport');
my $level = $q->param('level');
my $league = $q->param('league');
my $season = $q->param('season');
my $game_file = $q->param('game_file');

print header('text/xml');

open (IN, "< /home/realtin5/catalog/$sport/$level/$league/$season/$game_file") or die "Cannot open file. $!\n";

while (<IN>) {
	print $_;
}

