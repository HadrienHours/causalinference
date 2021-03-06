#!/bin/bash
#Check for State = 1 (closed), 
#create csvfile concatenating all the pars for a closed cnx, 
#put all the logfiles in treated.dir and the csvfile in a totreat.dir

NARGS=6

if [ ! $# -eq $NARGS ]
then
        echo "Usage check_end_cnxs:<pattern><outdir><listpars><user><db><tbl>"
        exit 1
fi

pattern=$1
outdir=$2
listpars=$3
user=$4
db=$5
tbl=$6
curdir=`pwd`
treated=$outdir/treated.dir
totreat=$outdir/totreat.dir
patternf=$(echo $pattern | tr / "\n" | tail -1)
srcip=$(echo $patternf | cut -d _ -f1 | tr - .)
dstip=$(echo $patternf | cut -d _ -f3 | tr - .)
srcport=$(echo $patternf | cut -d _ -f2)
dstport=$(echo $patternf | cut -d _ -f4)

verbose=2

if [ ! -d $totreat ]
then
        mkdir $totreat
fi

if [ ! -d $treated ]
then
        mkdir $treated
fi
outfile=$pattern\_$(date +"%d%m%y-%H%M%S").csv
echo "srcip,dstip,srcport,dstport,datets,$(head -1 $listpars | sed -re 's/\\\|/,/g')" > $outfile
for l in $(ls -rt $pattern* | egrep -v "*.csv")
do
        if [ -f $l ]
        then
                ts_sec=$(cat $l | head -1 | cut -d , -f1 | cut -d : -f2 | egrep -o "[0-9]+")
                ts_usec=$(cat $l | head -1 | cut -d , -f2 | cut -d : -f2 | egrep -o "[0-9]+")
                ts="$ts_sec"."$ts_usec"
                datets=$(date +"%Y-%m-%d %H:%M:%S.%N" -d@$ts)
                body=$(cat $l | grep -v "Timestamp" | egrep -v "^[ ]*$" | cut -d = -f2 | tr "\n" ,)
                echo $srcip,$dstip,$srcport,$dstport,$datets,$ts,$body >> $outfile
                rm -f $l
                #mv $l $treated
                #if [ $verbose -gt 0 ]
                #then
                #       echo "$l moved to $treated"
                #fi
        fi
done

#Remove the trailing comas
cat $outfile | sed -re 's/,$//g' > tmp_csv
mv tmp_csv $outfile

if [ $verbose -gt 0 ]
then
        echo "$outfile $totreat"
fi

mv $outfile $totreat

fout=$(echo "$outfile" | tr / "\n" | tail -1)
if [ $verbose -gt 0 ]
then
        echo "About to launch upload_pars: $totreat/$fout $user $db $tbl $treated"
fi
$curdir/upload_pars $totreat/$fout $user $db $tbl $treated

