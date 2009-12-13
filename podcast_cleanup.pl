#!/usr/bin/perl -w
#===============================================================================
#
#         FILE:  podcast_cleanup.pl
#
#        USAGE:  ./podcast_cleanup.pl 
#
#  DESCRIPTION:  Perl-Script to clean up MP3s after downloading via gPodder
#
#      OPTIONS:  ---
# REQUIREMENTS:  ID3 mass tagger <http://home.wanadoo.nl/squell/id3.html>
# 				 metamp3 <http://www.hydrogenaudio.org/forums/index.php?showtopic=49751>
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Martin Leyrer (m3), <leyrer@gmail.com>
#      COMPANY:  ---
#      VERSION:  1.0
#      CREATED:  08.12.2009 17:44:28 Westeuropäische Normalzeit
#===============================================================================

use strict;
use File::stat;
use File::Spec;
use File::Copy;


my $logfile = 'D:\Dokumente und Einstellungen\m3\Eigene Dateien\Projekte\Podcast-Cleanup\log.txt';
my $metamp3 = 'd:\Utilities\metamp3.exe';
my $id3		= 'd:\Utilities\id3.exe';

open(LOG, ">>$logfile") or die "Schreibfehler LOG! - $!\n";


my $fn		= ( not defined( $ENV{"GPODDER_EPISODE_FILENAME"} ) ) ? 
					$ARGV[0] : $ENV{"GPODDER_EPISODE_FILENAME"};
my ($volume,$podcastdir,$file) = File::Spec->splitpath( $fn );
$podcastdir = $volume . $podcastdir;

$fn =~ /(^|\\|\/)([^\\\/]+)(^|\\|\/)([^\\\/]+)([^\\\/]+)$/i;
my $title	= $ENV{"GPODDER_EPISODE_TITLE"};
my $pubdate	= $ENV{"GPODDER_EPISODE_PUBDATE"};
my $jahr;
if(not defined ($ENV{"GPODDER_EPISODE_PUBDATE"}) ) {
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(stat($fn)->mtime);
	$jahr = 1900 + $year;
} else {
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($pubdate);
	$jahr = 1900 + $year;
}

Check4Cover($podcastdir);

if( $fn =~ /StackOverflow/i ) {
	StackOverflow($fn);
}

print LOG "\n";
close(LOG);
exit;

sub StackOverflow {
	my ($filename) = @_;
	my $cmd;

	print LOG "Working on '$filename' ...\n";
	my $cover = getCover($filename);
	
	$cmd = "$metamp3 --pict $cover.png $filename";
	print LOG "$cmd\n";
	system($cmd);

	if( defined $title and $title ne '' ) {
		$cmd = "$id3 -2 -1 -M -y $jahr -t \"$title\" $filename";
		print LOG "$cmd\n";
		system($cmd);
	}
}

sub getCover {
	my($f) = @_;
	$f =~ /^(.*?)\\[^\\]+$/i;
	return("$1\\cover");
}

sub Check4Cover {
	my($dir) = @_;
	my $src = $dir . "cover";
	my $dst = $dir . "cover.png";
	print "$src => $dst\n";
	if( not -f $dst ) {
		copy($src, $dst);
	}
}

