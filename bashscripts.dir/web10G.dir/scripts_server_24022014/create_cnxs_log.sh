#!/bin/bash
NARGS=10

if [ ! $NARGS -eq $# ]
then
        echo "$# args given instead of $NARGS"
        echo create_cnx_log cnx srcip dstip srcport dstport listpars outputdir user@databasemachine datatabase tablename
        exit 1
fi

cnx=$1
srcip=$2
dstip=$3
srcp=$4
dstp=$5
listpars=$6
outdir=$7
usr=$8
db=$9
tbl=${10}
curdir=`pwd`

verbose=2

#create fileout name
pattern=$outdir/"$(echo $srcip | tr . -)"_"$srcp"_"$(echo $dstip | tr . -)"_$dstp
patternf=$(echo $pattern | tr / "\n" | tail -1)
fout="$pattern"_"$(date +%s)"
if [ $verbose -gt 1 ]
then
        echo "About to create logfile for cnx $1 and pattern $pattern"
        read input
fi
#store the data
readvars $1 | grep -v "HCSumRTT\|PreCongSumRTT\|PostCongSumRTT" | grep $(head -1 $listpars) > $fout
#get cnxs state
state=$(cat $fout | grep "State" | cut -d = -f2)
#closed, lastack,timewait
if [[ $state -eq 1 || $state -eq 9 || $state -eq 11 ]]
then
        if [ $verbose -gt 1 ]
        then
                echo "Connection finished for pattern $patternf"
        fi
        p=$(find $outputdir -iname "$patternf*_fin" | wc -l | cut -d \  -f1)
        if [ $p -eq 0 ]
        then

                pr=$(find $outputdir -iname "$patternf*" | egrep -v "*_fin" | wc -l | cut -d \  -f1)
                if [ $pr -eq 1 ]
                then
                        if [ $verbose -gt 1 ]
                        then
                                echo "Connection already studied or already closed"
                                echo "Removing log file for pattern $patternf"
                        fi
                        rm $fout
                else
                        fout2=$(echo "$fout"_fin)
                        mv $fout $fout2
                        if [ $verbose -gt 0 ]
                        then
                                echo "Cnxs flagged as finished ($fout2)"
                                echo "Cnxs flagged as finished ($fout2)"
                                echo "Launching check_end_cnxs $pattern $outdir $listpars $usr $db $tbl"
                                read input
                        fi
                        $curdir/check_end_cnxs $pattern $outdir $listpars $usr $db $tbl
                fi

        else
                if [ $verbose -gt 1 ]
                then
                        echo "Connection already flagged as finished, logfile removed for pattern $pattern"
                fi
                rm $fout
        fi
fi

