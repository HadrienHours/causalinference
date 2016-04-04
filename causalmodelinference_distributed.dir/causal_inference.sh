#!/bin/bash

NARGS=6

if [ $# -ne $NARGS ]
then
	echo "Usage of $(echo $0 | awk -F / '{print $NF}'):<pathdataset><resultsdir><listworkers><alpha><N><S>"
	exit 1
fi

pathds=$1
pathresdir=$2
listmachines=$3
alpha=$4
N=$5
S=$6

verbose=2

if [ ! -d $pathresdir ]
then
	mkdir -p $pathresdir
else
	echo "$pathresdir already exists, overwrite ? Y/N (all results in this directory will be deleted !): "
	read input
	if [ "$input" == "Y" ]
	then
		rm -r $pathresdir
		mkdir $pathresdir
	fi
fi

listnodes_valid=$pathresdir/listvalid_nodes
if [ -f ${listnodes_valid} ]
then
	rm ${listnodes_valid}
fi

touch ${listnodes_valid}
#Test reachability of the workers
for node in $(cat $listmachines)
do
	val=$(ping -c 2 $node | egrep -o "[0-9]+% packet loss" | egrep -o "[0-9]+")
	if [ $val -eq 0 ]
	then
		if [ $verbose -gt 0 ]
		then
			echo "Machine $node added to valid machines"
		fi
		echo "$node" >> ${listnodes_valid}
	else
		echo "Machine $node, not reachable"
	fi
done

npars=$(head -1 $pathds | tr , "\n" | wc -l | cut -d \   -f1)

if [ $npars -lt 2 ]
then
	echo "Unexpected input dataset (csv file expected, with header)"
	exit 1
fi


#open a master ssh cnxs to dbhost
echo "Creating ssh-agent"
eval `ssh-agent`
ssh-add
SSH_PROC_ID=$!

careful=1

if [ $careful -gt 0 ]
then
	while read machine
	do
		echo "Testing ssh $machine:"
		ssh $machine "uname -n"
	done < ${listnodes_valid}
fi


flag_fin=0
listtestedindep=$pathresdir/listtested_indepedences.csv
condsetsize=-1

pathrestest=$pathresdir/results_indep_test.dir
if [ ! -d $pathrestest ]
then
	mkdir $pathrestest
fi

while [ $flag_fin -eq 0 ]
do
	condsetsize=$(( $condsetsize+1 ))
	#generate list of independences to test
	listindep_to_test=$pathresdir/listindependences_to_test_cond_set_size_${condsetsize}
	if [ $condsetsize -eq 0 ]
	then
		matlab -nodesktop -nosplash -nojvm -r "addpath('/homes/hours/PhD/matlab/kpc');set_path_2();generateindepfromlist3('',$condsetsize,$npars,'$listindep_to_test',$alpha);exit"
	else
		matlab -nodesktop -nosplash -nojvm -r "addpath('/homes/hours/PhD/matlab/kpc');set_path_2();generateindepfromlist3('$listtestedindep',$condsetsize,$npars,'$listindep_to_test',$alpha);exit"
	fi

	#check finite state
	nindep=$(( $(wc -l $listindep_to_test | cut -d \  -f1)-1 )) #-1 for header
	if [ $nindep -eq 0 ]
	then
		echo "No more independence to test for condset size $condsetsize"
		flag_fin=1
		continue
	else
		echo -e "\n\n*******************************\n\t$nindep independences to test for condset size $condsetsize\n*****************************\n\n"
	fi
	
	#create path results
	pathrestest_cond=$pathrestest/condset_${condsetsize}.dir
	if [ ! -d $pathrestest_cond ]
	then
		mkdir $pathrestest_cond
	fi

	#launch the tests on the different machines
	if [ $verbose -gt 1 ]
	then
		echo "About to start distribute indep test with the following cmd:"
		echo "python distributeJobs.py $pathds $listindep_to_test $listnodes_valid $pathrestest_cond $N $S $alpha"
	fi
	python distributeJobs.py $pathds $listindep_to_test $listnodes_valid $pathrestest_cond $N $S $alpha
	echo -e "\n\n**********************************************************\n"
	echo -e "Finished testing the different independences for conditioning set size $condsetsize"
	echo -e "\n\n**********************************************************\n"

	#reformatting the indepedences: median_global_format X,Y,Z0,S,N,median(Pvals),min(Pvals),max(Pvals),std(Pvals),median(Stats),min(Stats),max(Stats),std(Stats)
	if [ $condsetsize -eq 0 ]
	then
		fieldz=3
	else
		fieldz=$(( $condsetsize+2 )) #X,Y
	fi
	find $pathrestest_cond -iname "median_global*" -exec cat {} \; | cut -d , -f1-$fieldz,$(( $fieldz+3 )) > $pathresdir/results_testindependences_cond_set_${condsetsize}.csv
	if [ $condsetsize -eq 0 ]
	then
		echo "X,Y,Z1,pval" > $listtestedindep
		cat $pathresdir/results_testindependences_cond_set_${condsetsize}.csv >> $listtestedindep
	else
		header="X,Y"
		for (( ii=1;ii<=$condsetsize;ii++ ))
		do
			header="$header,Z$ii"
		done
		header="$header,pval"
		echo $header > ${listtestedindep}_temp
		#bugfix for condset 0 already Z1 = 0 everywher 
		if [ $condsetsize -eq 1 ]
		then
			cat $listtestedindep | grep -v "X,Y" >> ${listtestedindep}_temp
		else
			cat $listtestedindep | grep -v "X,Y" | sed -re 's/([^,]+)$/\,\1/1' >> ${listtestedindep}_temp
		fi
		cat $pathresdir/results_testindependences_cond_set_${condsetsize}.csv >> ${listtestedindep}_temp
		mv ${listtestedindep}_temp $listtestedindep
	fi

	echo "Finished the indepedence test for the conditioning size $condsetsize"		
done

kill ${SSH_PROC_ID}
