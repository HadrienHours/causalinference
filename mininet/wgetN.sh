#!/bin/bash

NARGS=3

if [ $# -lt $NARGS ]
then
	echo "Wrong number of arguments:<ip><port><number of dl>"
	exit 1
fi

ip=$1
port=$2
N=$3

for (( i=1;i<=$N;i++ ))
do
	echo -e "\n**********"
	echo "Starting downloading file $i/$N"
	echo -e "**********\n" 
	wget -O temp_test $ip:$port
	rm -f temp_test
	echo -e "\n**********"
	echo "Finished downloading file $i/$N"
	echo -e "**********\n" 

	sleep 60
done
