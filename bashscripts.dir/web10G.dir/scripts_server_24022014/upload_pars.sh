#Check the totreat.dir if file present upload it to the table in psql db, move file to treated.dir
NARGS=5

if [ ! $# -eq $NARGS ]
then
        echo "upload_pars:<csvfile><usr><db><tbl><outdir>"
        exit 1
fi

csvfile=$1
usr=$2
db=$3
tbl=$4
outdir=$5

verbose=2
if [ $verbose -gt 1 ]
then
        echo "csvfile is $csvfile"
fi

csvfilename=$(echo $csvfile | tr / "\n" | tail -1)
if [ $verbose -gt 1 ]
then
        echo "About to copy csv file as scp $csvfile $usr:/tmp"
fi
scp $csvfile $usr:/tmp/
if [ $verbose -gt 0 ]
then
        echo "About to copy csvfile to db as: ssh $usr \"psql $db -c \\\"COPY $tbl from '/tmp/$csvfilename' DELIMITER ',' CSV HEADER\\\" \""
fi
ssh $usr "psql $db -c \"COPY $tbl from '/tmp/$csvfilename' DELIMITER ',' CSV HEADER\" "
if [ $verbose -gt 1 ]
then
        echo "Remove csv file as ssh $usr \"rm /tmp/$csvfilename\""
fi
ssh $usr "rm /tmp/$csvfilename"
if [ $verbose -gt 0 ]
then
        echo "Moving csvfile to treated dir $outdir"
fi
mv $csvfile $outdir

