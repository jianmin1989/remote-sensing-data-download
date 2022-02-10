#!/usr/bin/perl

##################################################################################
#
# Developed for downloading LANDSAT ARD data based on the csv list ###############
#
##################################################################################



######### host address & download directory & time period of data#################
($STA, $DTE, $GEO)=(0, 0, 1);    ### Type of data, BIL, DTED, and GeoTIFF 
$dirin = "/hunter/data1/wangj/SRTM/";		### directory of the csv 
$filelist = "SRTM_V3_267958.csv";			### csv name ARD_TILE_264952.csv, ARD_TILE_265163.csv, ARD_TILE_265164.csv, ARD_TILE_265168.csv, ARD_TILE_265169.csv
$col = 23;  ##specify the column number which stores the download link, start with 0, 1, 2, ... 
$fnelement = 5;    ##for example https://earthexplorer.usgs.gov/browse-link/14320/LE07_CU_029005_20160705_C01_V01, use / to split the link and the 5th (start from 0) element is the file name 

$dirout = "/hunter/data1/wangj/SRTM/";		## Output directory
#$dirout = "/home/wangj/Downloads/";		## Output directory  
#$subdir = 0; ### 1: different sub or 0: the same directory
$cookie = "/hunter/data/jianmin/codes/data_download/cookies.txt";	# cookie fullname
$head = 1 ; #### how many lines to skip in the filelist file		## head lines of csv
######### host address & download directory & time period of data#################

#####sub time##################
sub printtime(){
	$local=localtime;  ##in format Fri Oct 11 17:38:59 2014 ##
	@weekday = ("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"); 
	($SEC,$MIN,$HOUR,$MDAY,$MON,$YEAR,$WDAY,$YDAY,$ISDST) = localtime;
	#($_[0], $_[1], $_[2], $_[3], $_[4], $_[5], $_[6], $_[7], $_[8]); 
	$YEAR = $YEAR + 1900; 
	$MON += 1; 
	print "Formated time = $MDAY/$MON/$YEAR $HOUR:$MIN:$SEC  $weekday[$WDAY]\n"; 	
}
#####sub time##################




print "Start at ";
printtime();
$stime=localtime;
############################## Download #########################################
@ddindex = ($STA, $DTE, $GEO);
$filelist = join('', $dirin, $filelist);
open(IN,"<$filelist")||die "cannot open file";
#### $line = <IN>; ######To skip the first line
$nfile=0;

@fsta=();
@fdte=();
@fgeo=();

@outsta=();
@outdte=();
@outgeo=();
#$org="https://earthexplorer.usgs.gov/download/options/8360/SRTM1N29W102V3/";
#$csvorg="https://earthexplorer.usgs.gov/browse-link/8360/SRTM1N29W102V3";
#$URL="https://earthexplorer.usgs.gov/download/8360/SRTM1N29W102V3/GEOTIFF/EE";
while($line = <IN>){
	next if $. <= $head ;  ##### To skip the first line
	chomp $line;
#print "1. $line\n";
	$file=(split ",", $line)[$col];
#print "2. $file\n";
	$fname=(split "/", $file)[$fnelement];
#print "3. $fname\n$file\n";
	$file=~s/browse-link/download/;
#print "4. $file\n";
	
	$fname=~m/SRTM1N(\d+)W(\d+)V3/;
	$nn = $1;
	$ww = $2;

	if($STA!=0) {
		$tmp=join('', $file, "/STANDARD/EE");
		push(@fsta, $tmp);
		push(@outsta, join('', 'n', $nn, '_w', $ww, '_1arc_v3_bil.zip'));  #n29_w102_1arc_v3_bil.zip 
		#print "5. ", join('', $fname, '_SR.tar'), "\n";
	}
	if($DTE!=0) {
		$tmp=join('', $file, "/DTED/EE");  
		push(@fdte, $tmp);
		push(@outdte, join('', 'n', $nn, '_w', $ww, '_1arc_v3.dt2')); ##n29_w102_1arc_v3.dt2
	}
	if($GEO!=0) {
		$tmp=join('', $file, "/GEOTIFF/EE");
		push(@fgeo, $tmp);
		push(@outgeo, join('', 'n', $nn, '_w', $ww, '_1arc.tif'));  #n29_w102_1arc_v3.tif
	}
	
	$nfile++;
	#print "$fn[$i] $i\n";
	#$i = $i + 1;
}
close IN;

print "There are in total ", scalar(@fsta), " BIL, \n
			  ", scalar(@fdte), " DTED,  \n
			  and ", scalar(@fgeo), " GeoTIFF to be downloaded!\n" ;


unless(-d $dirout) {
     mkdir $dirout;
}
chdir $dirout || die ; 
print "The download directory is: $dirout\n";

print "nfile=$nfile\n";
#$ind=system("wget --save-cookies cookies.txt --keep-session-cookies --post-data 'username=xxxxxx&password=xxxxx' --delete-after https://ers.cr.usgs.gov/login/");
for($id=0;$id<$nfile;$id++){   ##$nfile
	if($STA!=0){
		$ind=system("wget -q -nc --load-cookies $cookie $fsta[$id] --trust-server-names -O $outsta[$id]"); 
		if($ind==256) {print "data $outsta[$id] is already exisiting!\n"}
		elsif($ind!=0) {print "data $outsta[$id] cannot be downloaded from $fsta[$id].\n";}
	}
	if($DTE!=0){
		$ind=system("wget -q -nc --load-cookies $cookie $fdte[$id] --trust-server-names -O $outdte[$id]"); 
		if($ind==256) {print "data $outdte[$id] is already exisiting!\n"}
		elsif($ind!=0) {print "data $outdte[$id] cannot be downloaded from $fdte[$id].\n";}
	}
	if($GEO!=0){
		$ind=system("wget -q -nc --load-cookies $cookie $fgeo[$id] --trust-server-names -O $outgeo[$id]"); 
		print("wget --load-cookies $cookie $fgeo[$id] --trust-server-names -O $outgeo[$id]\n");
		if($ind==256) {print "data $outgeo[$id] is already exisiting!\n"}
		elsif($ind!=0) {print "data $outgeo[$id] cannot be downloaded from $fgeo[$id].\n";}
	}
	
	$remain=($id+1) % 100;
	if($remain==0) { print "the file ", $id+1, " has been downloaded! started from file 1.\n"; }
	#print "the file ", $id+1, " has been downloaded! started from file 1.\n"; 
}

############################## Download #########################################


print "End at ";
printtime();
$etime=localtime;
print("\n\nFrom $stime to $etime\n");

