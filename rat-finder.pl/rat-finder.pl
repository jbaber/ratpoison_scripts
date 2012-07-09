#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  rat-finder.pl
#
#        USAGE:  ./rat-finder.pl
#
#  DESCRIPTION:  browse files of a given .*pattern.*\.extension with ratmenu
#
#      OPTIONS:  ---
# REQUIREMENTS:  perl
#         BUGS:  ---
# 				extension:c  app:touch /tmp/hi; gvim 
#        NOTES:  ---
# 				Too much IO. It doesn't really slows the app, but it's
# 				definately not needed to open/close the config file 3 times!
# 				(Hey, I'm starting with perl ;)
#
# 				If the extension == 'gen' rat-finder.pl will rebuild the file database
#       AUTHOR:   (kidd), <raimonster@gmail.com>
#      COMPANY:  
#      VERSION:  1.0
#      CREATED: 06/10/2007
#     REVISION:  ---
# 	  02/19/08: if you give a command as a filetype, it executes the command.
# 	  02/19/08: if you enter a window name as a filetype, it goes to that window
#     12/11/07 if rat-finder only finds one file of a given extension, it loads it without 
#     prompting ratmenu
#     12/11/07 esc when giving an aplication to open files exits the app
# :TODO:07/03/2007:: prefixar la comanda. p perl => ext=pdf, pattern=perl
#===============================================================================

use strict;
use warnings;
# :TODO:11/11/07:: parchear ratmen per acceptar G,g 

sub checkX {
#	system('ps' ,'axuf', 'X');
	return 1 if (exists $ENV{DISPLAY});
	return 0;
}	# ----------  end of subroutine checkX  ----------

sub rpecho {
	if (defined$ENV{"RATPOISON"})
	{
		system("ratpoison -c \"echo @_\"")
	}else{
		my $README;
		open($README, "zenity --info --text=\"@_\" |") or die("Couldn't fork: $|\n");
		close($README);
	}
	return ;
}	# ----------  end of subroutine rpecho  ----------
sub rpprompt {
	if (defined$ENV{"RATPOISON"})
	{
	return `ratpoison -c \"prompt @_\"`;
	}else{
		my $README;
		open($README, "zenity --entry --text=\"@_\" |") or die("Couldn't fork: $|\n");
		my $res;
		while (<$README>)
		{
			$res = $_;
		}
		close($README);

		if ($? != 0) { # $? es -1 si no se pudo ejecutar
			return "(null)";
		}
		return $res;
	}
}	# ----------  end of subroutine rpprompt  ----------


sub getLastFt {
	my	$INFILE_file_name = shift or die ("$0: no hay archivo de config?");
	open  my $INFILE, '<', $INFILE_file_name
		or die  "$0 : failed to open  input file '$INFILE_file_name' : $!\n";
	my	@file=<$INFILE>;
	close  $INFILE
		or warn "$0 : failed to close input file '$INFILE_file_name' : $!\n";

	my	$ft2;
		if ($file[0] =~ m/^lastft:(.*)$/mig){
			$ft2=$1;
	}
	return $ft2;
}	# ----------  end of subroutine getLastFt  ----------

sub setLastFt {
	my	($fileext,$ext)	= @_;

	open  my $INFILE, '<', $fileext or die  "$0 : failed to open  input file $fileext : $!\n";
	open  my $NEWFILE, '>', "${fileext}.new" or die  "$0 : failed to open  input file ${fileext}.new : $!\n";

	while (<$INFILE>)
	{
		s/^lastft:.*/lastft:${ext}/im;
		print $NEWFILE $_;
	}
	close  $INFILE
		or warn "$0 : failed to close input file $fileext : $!\n";
	close  $NEWFILE
		or warn "$0 : failed to close input file ${fileext}.new : $!\n";
	rename($fileext,"${fileext}.orig");
	rename("${fileext}.new",$fileext);
	return ;
}	# ----------  end of subroutine setLastFt  ----------

sub choosePattern {
	my	$pattern= rpprompt("Pattern?:");
	chomp($pattern);
	unless ( $pattern=~m/./ ) {                     # Space == space
		$pattern='.';                                
	}
	if ( $pattern =~ m/\(null\)/ ) {
		exit;
	}
	return $pattern;
}	# ----------  end of subroutine choosePattern  ----------

#locate  -U . -l0 -o filedb.db
#locate -d ./filedb.db mp3

my	$ext_app_file = '~/bin/ext_app.txt';
my	$dbname="~/filedb.db";
my	$directori="~/..";
my	$playPath = "~/bin/";
my $ratmenFlags = "--background green --foreground black";
my $ratmen = "ratmen";
#my $ratmen = "~/bin/termmen";
$ext_app_file =~ s{ ^ ~ ( [^/]* ) }
{ $1
	? (getpwnam($1))[7]
	: ( $ENV{HOME} || $ENV{LOGDIR}
	|| (getpwuid($>))[7]
	)
}ex;

 unless (-e $ext_app_file) #comprobar que existe el archivo de configuracion
 {
	 open(FILEHANDLE, ">$ext_app_file") || die("cannot open file: " . $!);
	 print FILEHANDLE "lastft:\n";
	 close(FILEHANDLE);
 }

my	$lastft = &getLastFt($ext_app_file);
my	$ft=rpprompt("Filetype($lastft):");
chomp($ft);

unless ( $ft=~m/[^ ]/ ) {                       # Space == null
	$ft=$lastft;                                # blank means repeat last ext
}

#if ( $ft eq '(null)' ) {
if ( $ft =~ m/\(null\)/ ) {
	exit;                                       # escape == exit
}

if ( $ft eq "gen" ) {
	rpecho("Generating $dbname...");
	system("locate  -U $directori -l0 -o $dbname");
	rpecho("ERROR AL GENERAR $dbname") if ($? == 0);
	rpecho("$dbname Generated");
	exit;
}

#it can be used to launch other programs#{{{
if ( $ft eq "mp3" ) {
	system("$playPath/play.sh");                # // is not a problem in paths
	exit;                                       # mp3? we have a program to deal with it
}
# :TODO:08/03/2004:: firefox=ff
if ( $ft eq "ff" ) {
	system("firefox");                # // is not a problem in paths
	exit;                                       # mp3? we have a program to deal with it
}
# :TODO:08/03/2004:: firefox3=ff3
if ( $ft eq "ff3" ) {
	system("/tmp/firefox/firefox");                # // is not a problem in paths
	exit;                                       # mp3? we have a program to deal with it
}
# :TODO:08/03/2004:: vi=gvim
if ( $ft eq "vi" ) {
	system("gvim");                # // is not a problem in paths
	exit;                                       # mp3? we have a program to deal with it
}#}}}

my $pattern = &choosePattern;

open  my $INFILE, '<', $ext_app_file
	or die  "$0 : failed to open  input file $ext_app_file : $!\n";

#file format:
#ExtensionSpaceApp+flags
#lastft:pdf
#chm kchmviewer
#c gvim -U none
my $found=0;
my	$application;
foreach  ( <$INFILE> ) {
	chomp();
	if ( m/^$ft (.*)$/ ) {
		$found=1;
		$application=$1;
		last;
	}
}
close  $INFILE
or warn "$0 : failed to close input file $ext_app_file : $!\n";


if (! $found )
{
	if (`which $ft` =~ m/^\//)                  # si la ext, es el nombre de un ejecutable...
	{
		$pattern = "" if ($pattern =~ /^\.$/);
		rpecho(`$ft $pattern`);
		exit();
	}
	elsif (exists $ENV{'RATPOISON'}) # Si la ext es una substring de titulo de ventana
	{
		my @winlist = `ratpoison -c "windows"`;
		foreach my $i (@winlist)
		{
			if ($i =~ /^(\d+)[-+*].*$ft.*/i)
			{
				system("ratpoison -c \"select $1\"");
				exit();
			}
		}
	}

	my $openerApp = rpprompt("Give an application to open $ft files:");
	exit if ($openerApp =~/\(null\)/);

		open  my $OUTFILE, '>>', $ext_app_file
		or die  "$0 : failed to open  output file $ext_app_file : $!\n";

		print $OUTFILE "$ft $openerApp";
		$application = $openerApp;
		chomp($application);
	close  $OUTFILE
		or warn "$0 : failed to close output file $ext_app_file : $!\n";
}


unless ( $ft eq $lastft ) {
	setLastFt($ext_app_file, $ft);
}



#my	@FileList= `find $directori -type f -iname "*$pattern*\.$ft"`;
my	@FileList= `locate -d $dbname -i -r ".*$pattern\[\^\/\]*\\.$ft\$"`; # only search for filenames
#my	@FileList= `locate -d $dbname -i -r ".*$pattern.*\\.$ft\$"`; # search for both filenames and dirs


my	$comandoG;

if ( scalar @FileList == 1 ) {
	$comandoG = "$application " . quotemeta($FileList[0]);
}
else
{
	$comandoG="$ratmen $ratmenFlags ";
	foreach  ( @FileList ) {
		chomp;
		m/.*\/(.*)$/;

		$comandoG = $comandoG . quotemeta($1) . ' ' .'"' . "$application " . quotemeta($_) . '" ';
	}
}
#	print "$comandoG\n";
exec($comandoG);

# vim: set tabstop=4 shiftwidth=4 foldmethod=marker : ##
