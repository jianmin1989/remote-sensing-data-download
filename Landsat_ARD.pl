#!/usr/bin/perl

##################################################################################
#
# Developed for downloading LANDSAT ARD data based on the csv list ###############
#		By Jianmin Wang, Geospatial Sciences Center of Excellence
#			South Dakota State University
#    Contact jianmin.wang@sdstate.edu
#
# 1st, use https://earthexplorer.usgs.gov/ to filter the files you plan to download
# 2nd, in the collum "Search results" click "click here to export your results" to
#      save as "non-limited" and "csv"
# 3rd, get the browse-link in the last column in the csv and replace "browse-link" 
#      with "download/options"
# 4th, open the new link "....download/options...", press ctrl+u to get the source
#      page, search "onClick" and get the correct download link
##################################################################################



######### host address & download directory & time period of data#################
($SR, $TOA, $BT, $QA, $FRB, $META)=(1, 0, 0, 1, 1, 1);    ### Type of data
$dirin = "/gpfs/data/xyz/jianmin/LandsatARD/";		### directory of the csv 
$filelist = "ARD_TILE_265169.csv";			### csv name ARD_TILE_264952.csv, ARD_TILE_265163.csv, ARD_TILE_265164.csv, ARD_TILE_265168.csv, ARD_TILE_265169.csv
#$dirin="/home/wangj/Downloads/";
#$filelist= "ARD_TILE_265695.csv";

$dirout = "/gpfs/data/xyz/jianmin/LandsatARD/";		## Output directory
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
@ddindex = ($SR, $TOA, $BT, $QA, $FRB, $META);
$filelist = join('', $dirin, $filelist);
open(IN,"<$filelist")||die "cannot open file";
#### $line = <IN>; ######To skip the first line
$nfile=0;

@fsr=();
@ftoa=();
@fbt=();
@fqa=();
@ffrb=();
@fmeta=();

@outsr=();
@outtoa=();
@outbt=();
@outqa=();
@outfrb=();
@outmeta=();
#$org="https://earthexplorer.usgs.gov/download/options/14320/LE07_CU_029005_20081104_C01_V01/";
#$csvorg="https://earthexplorer.usgs.gov/browse-link/14320/LE07_CU_029005_20081104_C01_V01";
#$URL="https://earthexplorer.usgs.gov/download/14320/LE07_CU_029005_20081104_C01_V01/SR/EE";
while($line = <IN>){
	next if $. <= $head ;  ##### To skip the first line
	chomp $line;
#print "1. $line\n";
	$file=(split ",", $line)[36];
#print "2. $file\n";
	$fname=(split "/", $file)[5];
#print "3. $fname\n$file\n";
	$file=~s/browse-link/download/;
#print "4. $file\n";

	if($SR!=0) {
		$tmp=join('', $file, "/SR/EE");
		push(@fsr, $tmp);
		push(@outsr, join('', $fname, '_SR.tar'));
		#print "5. ", join('', $fname, '_SR.tar'), "\n";
	}
	if($TOA!=0) {
		$tmp=join('', $file, "/TOA/EE");
		push(@ftoa, $tmp);
		push(@outtoa, join('', $fname, '_TA.tar'));
	}
	if($BT!=0) {
		$tmp=join('', $file, "/BT/EE");
		push(@fbt, $tmp);
		push(@outbt, join('', $fname, '_BT.tar'));
	}
	if($QA!=0) {
		$tmp=join('', $file, "/QA/EE");
		push(@fqa, $tmp);
		push(@outqa, join('', $fname, '_QA.tar'));
	}
	if($FRB!=0) {
		$tmp=join('', $file, "/FRB/EE");
		push(@ffrb, $tmp);
		push(@outfrb, join('', $fname, '.jpg'));
	}
	if($META!=0) {
		$tmp=join('', $file, "/METADATA/EE");
		push(@fmeta, $tmp);
		push(@outmeta, join('', $fname, '.xml'));
	}
	$nfile++;
	#print "$fn[$i] $i\n";
	#$i = $i + 1;
}
close IN;

print "There are in total ", scalar(@fsr), " Surface Reflectance, \n
			  ", scalar(@ftoa), " Top Of Atmosphere,  \n
			  ", scalar(@fbt), " Brightness Temperature, \n
			  ", scalar(@fqa), " Quality Assessment, \n
			  ", scalar(@ffrb), " Full Resolution Browse, \n
			  and ", scalar(@fmeta), " Metadata to be downloaded\n";


unless(-d $dirout) {
     mkdir $dirout;
}
chdir $dirout || die ; 
print "The download directory is: $dirout\n";

print "nfile=$nfile\n";
#$ind=system("wget --save-cookies cookies.txt --keep-session-cookies --post-data 'username=xxxxxx&password=xxxxx' --delete-after https://ers.cr.usgs.gov/login/");
for($id=0;$id<$nfile;$id++){   ##$nfile
	if($SR!=0){
		$ind=system("wget -q -nc --load-cookies $cookie $fsr[$id] --trust-server-names -O $outsr[$id]"); 
		if($ind==256) {print "data $outsr[$id] is already exisiting!\n"}
		elsif($ind!=0) {print "data $outsr[$id] cannot be downloaded from $fsr[$id].\n";}
	}
	if($TOA!=0){
		$ind=system("wget -q -nc --load-cookies $cookie $ftoa[$id] --trust-server-names -O $outtoa[$id]"); 
		if($ind==256) {print "data $outtoa[$id] is already exisiting!\n"}
		elsif($ind!=0) {print "data $outtoa[$id] cannot be downloaded from $ftoa[$id].\n";}
	}
	if($BT!=0){
		$ind=system("wget -q -nc --load-cookies $cookie $fbt[$id] --trust-server-names -O $outbt[$id]"); 
		if($ind==256) {print "data $outbt[$id] is already exisiting!\n"}
		elsif($ind!=0) {print "data $outbt[$id] cannot be downloaded from $fbt[$id].\n";}
	}
	if($QA!=0){
		$ind=system("wget -q -nc --load-cookies $cookie $fqa[$id] --trust-server-names -O $outqa[$id]"); 
		if($ind==256) {print "data $outqa[$id] is already exisiting!\n"}
		elsif($ind!=0) {print "data $outqa[$id] cannot be downloaded from $fqa[$id].\n";}
	}
	if($FRB!=0){
		$ind=system("wget -q -nc --load-cookies $cookie $ffrb[$id] --trust-server-names -O $outfrb[$id]"); 
		if($ind==256) {print "data $outfrb[$id] is already exisiting!\n"}
		elsif($ind!=0) {print "data $outfrb[$id] cannot be downloaded from $ffrb[$id].\n";}
		
	}
	if($META!=0){
		$ind=system("wget -q -nc --load-cookies $cookie $fmeta[$id] --trust-server-names -O $outmeta[$id]"); 
		if($ind==256) {print "data $outmeta[$id] is already exisiting!\n"}
		elsif($ind!=0) {print "data $outmeta[$id] cannot be downloaded from $fsr[$id].\n";}
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





