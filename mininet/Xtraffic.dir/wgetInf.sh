#!/bin/bash

NARGS=3

if [ $# -lt $NARGS ]
then
	echo "Wrong number of arguments:<ip><port><file>"
	exit 1
fi

ip=$1
port=$2
file=$3

while :
do
	#echo -e "\n**********"
	#echo "Starting downloading $file "
	#echo -e "**********\n" 
	wget -q -O $file $ip:$port/$file
	rm -f $file
	#echo -e "\n**********"
	#echo "Finished downloading $file"
	#echo -e "**********\n" 
done
