#!/usr/bin/perl

##################################################################################
#
# Developed for downloading LANDSAT ARD data based on the csv list ###############
#		By Jianmin Wang, Geospatial Sciences Center of Excellence
#			South Dakota State University
#
# 1st, use https://earthexplorer.usgs.gov/ to filter the files you plan to download
# 2nd, in the collum "Search results" click "click here to export your results" to
#      save as "non-limited" and "csv"
# 3rd, get the browse-link in the last column in the csv and replace "browse-link" 
#      with "download/options"
# 4th, open the new link "....download/options...", press ctrl+u to get the source
#      page, search "onClick" and get the correct download link

#Find csvorg from the exported (Non-liminted) 
#$csvorg="https://earthexplorer.usgs.gov/browse-link/15920/2801825";
#$org="https://earthexplorer.usgs.gov/download/options/15920/2801825";
#$URL="https://earthexplorer.usgs.gov/download/15920/2801825/TIF/EE";



#$org="https://earthexplorer.usgs.gov/download/options/14320/LE07_CU_029005_20081104_C01_V01/";
#$csvorg="https://earthexplorer.usgs.gov/browse-link/14320/LE07_CU_029005_20081104_C01_V01";
#$URL="https://earthexplorer.usgs.gov/download/14320/LE07_CU_029005_20081104_C01_V01/SR/EE";
##################################################################################




use strict;
use warnings;
#use POSIX qw(strftime);
use Time::Piece;
use Parallel::ForkManager;




# run


my $stime=localtime;
my $time_start = time();
main();
my $time_end = time();
my $etime=localtime;
print("\n\nFrom $stime to $etime\n");
print "hours used: ", ($time_end-$time_start)/3600, "\n";




#**************************************************************************#
#***                       main function                                ***#
#**************************************************************************#
sub main {
	print "Start at ";printtime();
	my $dirin = "/hunter/data/jianmin/codes/data_download/USGSEE/";		### directory of the csv 
	my $filelist = "NAIP_Ponil_complex_2018.csv"; #"spring_2016_2019.csv";	NAIP_382269_fires_rodman_2016_2018.csv	ARD_TILE_382363_fires_rodman.csv   spring_2009_2015.csv	NAIP_382269_fires_rodman_2016_2018.csv
	### csv name ARD_TILE_264952.csv, ARD_TILE_265163.csv, ARD_TILE_265164.csv, ARD_TILE_265168.csv, ARD_TILE_265169.csv NAIP_Ponil_complex_2018.csv
	
	######### host address & download directory & time period of data#################	
	#For Landsat ARD, select elements from below
	#my @linkpost = ("/SR/EE", "/ST/EE", "/TOA/EE", "/BT/EE", "/QA/EE", "/FRB/EE", "/METADATA/EE");	
	#my @filepost = ("_SR.tar", "_ST.tar", "_TA.tar", "_BT.tar", "_QA.tar", ".jpg", "xml");
	#my $linkcol=36;	#For LandsatARD it is 36	
	#For NAIP, use
	#my @linkpost = ("/TIF/EE");	
	#my @filepost = (".zip");
	#my $linkcol=35;
	my @linkpost = ("/TIF/EE");	
	my @filepost = (".zip");
	my $linkcol=35;
	my $filecol=0;
	
	my $dirout = "/gpfs/data/xyz/jianmin/NAIPdata/Ponil_Complex/";		## Output directory
	my $cookie = "/hunter/data/jianmin/codes/data_download/USGSEE/cookies.txt";	# cookie fullname
	my $head = 1 ; #### how many lines to skip in the filelist file		## head lines of csv
	my $max_cores = 30;  # set max cores for parallel-processing, set 0 for dubug, 0 means do not parallel
	######### host address & download directory & time period of data#################


	# get commands
	chdir($dirout);
	$filelist = join('', $dirin, $filelist);
	my @cmds = get_download_commands (filelist => $filelist, head => $head, linkpost => \@linkpost, filepost => \@filepost, linkcol=> $linkcol, filecol => $filecol, pathout => $dirout, cookie => $cookie );
	#foreach my $cmd (@cmds) {
	#	my $outfile = (split(" ", $cmd))[-1];
	#	print "$outfile\n";
	#}
	my $nfiles=@cmds;
	print "There are totally $nfiles files to download\n\n";
	
	# set multi-processing
	my $pm = Parallel::ForkManager->new($max_cores);
	PARALLEL_PROCESSING:
	foreach my $cmd (@cmds) {
		my $outfile = (split(" ", $cmd))[-1];
		print "downloading $outfile\n";
		# if file exist, next
		#next if(() = glob("$outfile*"));
		next if (-e $outfile);
		
		# sleep 10 seconds, or the server may refuse to visit
		sleep (5);

		# forks and returns the pid for the child
		my $pid = $pm->start and next PARALLEL_PROCESSING;

		
		print "$cmd\n";
		my $error=system($cmd);
		if($error==256) {print "$outfile is already exisiting!\n"}
		elsif($error!=0) {print "$outfile cannot be downloaded\n";}

		$pm->finish;      # Terminates the child process
		
	}
	$pm->wait_all_children;     # wait all command be done

	print "End at ";printtime();
}





#####sub time##################
sub printtime(){
	my $local=localtime;  ##in format Fri Oct 11 17:38:59 2014 ##
	my @weekday = ("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"); 
	my ($SEC,$MIN,$HOUR,$MDAY,$MON,$YEAR,$WDAY,$YDAY,$ISDST) = localtime;
	#($_[0], $_[1], $_[2], $_[3], $_[4], $_[5], $_[6], $_[7], $_[8]); 
	$YEAR = $YEAR + 1900; 
	$MON += 1; 
	print "Formated time = $MDAY/$MON/$YEAR $HOUR:$MIN:$SEC  $weekday[$WDAY]\n"; 	
}
#####sub time##################





#**************************************************************************#
#                   Function: get_directory_links                          #
#**************************************************************************#

sub get_download_commands {
	# Aim:
	#   Get the directory links for given products and years  
	# return: an array contain the directory links

	my (%args) = @_;
	# set named arguments
	my $filelist = $args{filelist};
	my $head = $args{head};
	my @linkpost = @{$args{linkpost}};
	my @filepost = @{$args{filepost}};
	my $linkcol = $args{linkcol};
	my $filecol = $args{filecol};
	my $dirout = $args{pathout};
	my $cookie = $args{cookie};
	
	my $ndd = @linkpost;

	my @cmds;      # delcare 

	open(IN,"<$filelist")||die "cannot open file";
	#### $line = <IN>; ######To skip the first line
	while(my $line = <IN>){
		next if $. <= $head ;  ##### To skip the first line
		chomp $line;
		
		my @tmp=split ",", $line;
		my $link=$tmp[$linkcol];
		$link=~s/browse-link/download/;
		my $fname=$tmp[$filecol];
		
		for(my $id=0;$id<$ndd;$id++){
			my $url=join('', $link, $linkpost[$id]);
			my $file=join('', $dirout, $fname, $filepost[$id]);
			
			#next if (() = glob("$file*"));
			next if (-e $file);
			my $cmd = "wget -q -nc --load-cookies $cookie $url --trust-server-names -O $file"; 
			push(@cmds, $cmd);
		}
	}
		
	close IN;
	return @cmds;
} #### End function ###



