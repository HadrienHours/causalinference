#!/bin/bash
#Every period store the parameters corresponding to all cnxs 
#filtering out port 80 443 22 3306 & 5432, add ip, port and timestamp
#To be concatenated after the ouptut of each cnxs for each period must be stored
#in a file with name: srcip_dstip_srcport_dstport_ts
NARGS=6

if [ ! $# -eq $NARGS ]
then
        echo "Usage of cnxs_poll: period listpars outdir usr db tbl"
        exit 1
fi

period=$1
listpars=$2
outdir=$3
usr=$4
db=$5
tbl=$6
curdir=`pwd`

verbose=2
#testp set to 1 the script don't filter out the cnxs on port 80
testp=0

while true
do
        if [ $testp -gt 0 ]
        then
                nc=$(listconns | grep -v " 22 \| 443 \| 3306 \| 5432 \|CID \| -" | egrep -v "^$" | wc -l | cut -d \  -f1)
                if [[ ($verbose -gt 1) && ($nc -gt 0) ]]
                then
                        echo "Found $nc cnxs"
                        read input
                fi
                for (( i=1;i<=$nc;i++ ))
                do
                        cnx=$(listconns | grep -v " 22 \| 443 \| 3306 \| 5432 \|CID \| -" | egrep -v "^$" | head -$i | tail -1 | awk '{print $1}')
                        srcip=$(listconns | grep -v " 22 \| 443 \| 3306 \| 5432 \|CID \| -" | egrep -v "^$" | head -$i | tail -1 | awk '{print $2}')
                        srcp=$(listconns | grep -v " 22 \| 443 \| 3306 \| 5432 \|CID \| -" | egrep -v "^$" | head -$i | tail -1 | awk '{print $3}')
                        dstip=$(listconns | grep -v " 22 \| 443 \| 3306 \| 5432 \|CID \| -" | egrep -v "^$" | head -$i | tail -1 | awk '{print $4}')
                        dstp=$(listconns | grep -v " 22 \| 443 \| 3306 \| 5432 \|CID \| -" | egrep -v "^$" | head -$i | tail -1 | awk '{print $5}')
                        if [ $verbose -gt 1 ]
                        then
                                echo "create_cnxs_log $cnx $srcip $dstip $srcp $dstp $listpars $outdir $usr $db $tbl\&"
                        fi
                        $curdir/create_cnxs_log $cnx $srcip $dstip $srcp $dstp $listpars $outdir $usr $db $tbl &
                done

        else
                nc=$(listconns | grep -v " 22 \| 21 \| 80 \| 443 \| 3306 \| 5432 \|CID \| -" | egrep -v "^$" | wc -l | cut -d \  -f1)
                if [[ ($verbose -gt 1) && ($nc -gt 0) ]]
                then
                        echo "Found $nc cnxs"
                        read input
                fi
                for (( i=1;i<=$nc;i++ ))
                do
                        cnx=$(listconns | grep -v " 22 \| 21 \| 80 \| 443 \| 3306 \| 5432 \|CID \| -" | egrep -v "^$" | head -$i | tail -1 | awk '{print $1}')
                        srcip=$(listconns | grep -v " 22 \| 21 \| 80 \| 443 \| 3306 \| 5432 \|CID \| -" | egrep -v "^$" | head -$i | tail -1 | awk '{print $2}')
                        srcp=$(listconns | grep -v " 22 \| 21 \| 80 \| 443 \| 3306 \| 5432 \|CID \| -" | egrep -v "^$" | head -$i | tail -1 | awk '{print $3}')
                        dstip=$(listconns | grep -v " 22 \| 21 \| 80 \| 443 \| 3306 \| 5432 \|CID \| -" | egrep -v "^$" | head -$i | tail -1 | awk '{print $4}')
                        dstp=$(listconns | grep -v " 22 \| 21 \| 80 \| 443 \| 3306 \| 5432 \|CID \| -" | egrep -v "^$" | head -$i | tail -1 | awk '{print $5}')
			if [ $verbose -gt 1 ]
                        then
                                echo "create_cnxs_log $cnx $srcip $dstip $srcp $dstp $listpars $outdir $usr $db $tbl\&"
                        fi
                        $curdir/create_cnxs_log $cnx $srcip $dstip $srcp $dstp $listpars $outdir $usr $db $tbl &
                done
        fi
        ./sleepMS $(( $period*1000 ))

done
                                
