#!/usr/bin/perl

##################################################################################
#
# Developed for downloading MODIS daily products#               Dec 11 2015
#
##################################################################################



######### host address & download directory & time period of data#################
$host="http://e4ftl01.cr.usgs.gov";   
$dirc="/MOLT/MOD11A1.006/";
$outdirc="/gpfs/data/xyz/jianmin/westUS/MOD11A1/";
# $outdirc="/hunter/data1/wangj/Rosemount/MODISLST/";
unless(-d $outdirec) {
     mkdir $outdirc;
}

$ystart=2002;
$doystart=184;
$yend=2005;
$doyend=183;


#CONUS
#h08v04, h09v04, h10v04, h11v04, h12v04, h13v04
#h08v05, h09v05, h10v05, h11v05, h12v05
#h08v06, h09v06, h10v06
@tiles=("h08v04", "h08v05", "h09v04", "h09v05", "h10v04", "h10v05", "h11v04") ;
######### host address & download directory & time period of data#################


############################## main code #########################################
chdir $outdirc ||die ; 
print "The download directory is: $outdirc\n";

for($yy=$ystart;$yy<=$yend;$yy++){ 
   ##@md=(31,28,31,30,31,30,31,31,30,31,30,31);
   ##if((($yy%4)==0)&&((($yy%100)!=0)||(($yy%400)==0))) {@md=(31,29,31,30,31,30,31,31,30,31,30,31);}
   @md=(31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365);
   if((($yy%4)==0)&&((($yy%100)!=0)||(($yy%400)==0))) {@md=(31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366);} 
   print "$yy $md[2]\n";
   $doys=1;
   if ($yy==$ystart) {$doys=$doystart;}
   $doye=361;
   if ($yy==$yend) {$doye=$doyend;}
  # print "$yy $doys $doye\n";

   for($doy=$doys;$doy<=$doye;$doy=$doy+1){
      #print "$yy $doys $doye \n";
      for($mm=1;$mm<=12;$mm++){
         # print "$doy $md[$mm-1] \n";
          if($doy<=$md[$mm-1]) { last; } 
      }
      if($mm==1) {$dd=$doy;
      } else {$dd=$doy-$md[$mm-2];}
     # print "$mm $dd $doy\n";
      $datedirc=join('.',$yy,sprintf("%02s", $mm),sprintf("%02s", $dd) );
      $URL=join('',$host, $dirc, $datedirc, "/"); 
      $fileindex=join('',$outdirc,"index", $ystart, ".html");
      if(-e $fileindex){unlink $fileindex;}
      # print "$URL\n";
      system("wget -O $fileindex -q $URL"); ##generate file of index.html
      open(IN,"<$fileindex")||die "cannot open file";
      @alld=<IN>;
      close IN;

      foreach $tile(@tiles){
	      $ind=0;
	      foreach $line(@alld){
		   chomp($line);
		   if($line=~m/hdf">MOD11A1.*$tile/){
		        $file=(split('>',$line))[2];
		        $file=(split('<',$file))[0];
		        $URLfile=join('', $URL, $file); # exact file                     
		        $ind2=system("wget -q -nc --user=xxxxxx --password=xxxx $URLfile"); ##get the hdf file
		        #print "Downloaded $file\n";
		        if($ind2==0) {$ind=1;}                ######Please doubly check how ind2 repond to the downloading process. ##########
			else {$ind=2;}
		   }
	      }
	      if($ind==0){print "data in tile $tile on $datedirc is missed.\n";}
	      if($ind==2){print "data in tile $tile on $datedirc cannot be downloaded.\n";}
      }

   }

}  ##end for $yy
if(-e $fileindex){unlink $fileindex;}
############################## main code #########################################
