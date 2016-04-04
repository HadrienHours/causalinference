#!/bin/bash
 
verbose=1
#filelist=$1
ftp='193.55.113.113'
#ftp='blagny'
user='horus_client'
psw='gaiours&2013'
dlc=0
SPOTS=10   # Modulo 30 gives range 0 - 29.      
counter=0
 
# total=$(wc -l $filelist | cut -d \  -f1)
while : 
do

   let "numb = ($RANDOM % $SPOTS + 1)*10" # file number.
 #   l = $f$numb$m

FF="file${numb}M"
	    echo " "
	    echo "----------------------------------"
	    date
	    echo "About to start downloading file: $FF"
#echo $FF
#  echo "About to start downloading PPPPXX : file${numb}M  "
 
	
ftp -n -v $ftp << EOT
ascii
user $user $psw
prompt
get $FF  /dev/null
bye
EOT

	if [ $verbose -gt 0 ]
        then
		counter=$(( $counter+1 ))
                echo "Finished downloading file:  $FF"
		echo "Total number of downloads:  $counter"
        fi
sleep 5
done

  
