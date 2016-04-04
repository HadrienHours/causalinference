!/bin/bash     

if [ ! $EUID -eq 0 ]
then
   echo "This script must be run as root" 1>&2
   exit 1
fi

NARGS=8
if [ ! $# -eq $NARGS ]
then
        echo "Usage of $(echo $0 | cut -d / -f2):<period(ms)><listpars><user@databasemachine><database><tablename><path_logfiles.dir><interface><path_to_pcap_trace>"
        exit 1
fi

#`ssh-agent`
#ssh-add

period=$1
listpars=$2
user=$3
db=$4
tbl=$5
outdir=$6
ifce=$7
tracefile=$8

verbose=2

if [ ! -d $outdir ]
then
        sudo -u horus mkdir $outdir
fi

sudo -u horus cat $listpars | cut -d \  -f1 > listnamespars
sudo -u horus cat $listpars | cut -d \  -f2 > listtypespars

npars=$(wc -l listnamespars | cut -d \  -f1)
tpars=$(wc -l listtypespars | cut -d \  -f1)

if [[ $npars -eq 0 || $tpars -eq 0 || ! $npars -eq $tpars ]]
then
        echo "The list of parameters must be:<namepar> <typepars(mysql)>"
        exit 1
fi


################
# Create table #
################
pres=$(ssh $user "psql $db -c \"select count(*) from pg_tables where schemaname = 'public' and tablename = '$tbl'\" " | grep -v 'count\|-\|row' | egrep -o "[0-9]+")
if [ $pres -lt 1 ]
then
        ssh $user "psql $db -c \"CREATE TABLE $tbl (srcip inet, dstip inet, srcport integer, dstport integer,datets timestamp)\" "
        for ((l=1;l<=$npars;l++))
        do
                parn=$(head -$l listnamespars | tail -1)
                part=$(head -$l listtypespars | tail -1)
                ssh $user "psql $db -c \"ALTER TABLE $tbl ADD COLUMN $parn $part\" "
        done
fi

##################
# Launch tcpdump #
##################
#Filter out (in this order) chalon caratroc xlan horus and ssh connexion and ftp cmd cnxs and http and smpt and https and psql
sudo tcpdump not host 172.17.21.23 and not host 192.168.104.134 and not host 172.17.20.143 and not host 192.168.104.163 and not port 22 and not port 21 and not port 80 and not port 443 and not port 3306  and not port 5432 -i $ifce -w $tracefile &
if [ $verbose -gt 1 ]
then
        echo "Pcap trace will saved in $tracefile"
fi



##########################
# Launch modprobe estats #
##########################
sudo modprobe tcp_estats_nl

##############################
# Poll the cnxs every period # Every period store the parameters corresponding to all cnxs filtering out port 80 443 22 3306 & 5432, add ip, port and timestamp
##############################
listpars2=listnamesparsgrep_$(date +%s)
sudo -u horus touch $listpars2
for l in $(cat listnamespars)
do
        echo "$l\\|" >> $listpars2
done
#cat $listpars2
#read input
sudo -u horus cat $listpars2 | tr -d "\n" | sed -re 's/\\\|$//'> tmp
#cat tmp
#read input
sudo -u horus mv tmp $listpars2
curdir=`pwd`
if [ $verbose -gt 0 ]
then
        echo "Launching cnxs poll script $period $listpars2 $outdir $user $db $tbl\&"
        #read input
fi
sudo $curdir/cnxs_poll $period $listpars2 $outdir $user $db $tbl &
