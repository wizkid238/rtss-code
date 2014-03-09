package rtss;

use strict;
use warnings;
use Exporter;
use XML::Simple;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION     = 1.00;
@ISA         = qw(Exporter);
@EXPORT      = ();
@EXPORT_OK   = qw(search_file);
%EXPORT_TAGS = ( DEFAULT => [qw(&search_file)],
		 SEARCH => [qw(&search_file)]
	       );

sub search_file {
        my ($filename, $grep_line, $grep_for) = @_;
        open my $fh, "<", "$filename" or die "Couldn't read '$filename': $!\n";

        my $data = XMLin ($fh);
        #print Dumper ( $data );
        #foreach my $attr (keys %{$data->{GAME}}) {
        my $attr = $data->{$grep_line}->{$grep_for};
        close $fh;
        return $attr;
}

