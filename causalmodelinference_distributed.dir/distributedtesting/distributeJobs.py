#!/usr/bin/python
# -*- coding: utf-8 -*-

import psycopg2
import sys
import csv
import os
import time
import threading
import Queue
import logging
import signal
import subprocess
queue = None

stop_threads = threading.Event()

def signal_handler(sig,frame):
	if sig -- signal.SIGINT:
		os.kill(os.getpid(),9)
		sys.exit(0)
	#endif
#enddef

def populateQueue(pathcondlist,pathds,pathmatlab,alpha,N,l):
	with open(pathcondlist,'rb') as csvfile:
		filereader=csv.reader(csvfile,delimiter=',');
		next(filereader, None)  # skip the headers
		for row in filereader:
			x = row[0]
			y = row[1]
			lr = len(row)
			if lr == 2:
				z = 0;
				args='./nodebashtest '+dbhost+' '+dbname+' '+tablename+' <NODE> '+pathmatlab+' '+pathds+' '+str(alpha)+' '+str(N)+' '+str(l)+' '+str(x)+' '+str(y)+' '+str(z)
			else:
				args='./nodebashtest '+dbhost+' '+dbname+' '+tablename+' <NODE> '+pathmatlab+' '+pathds+' '+str(alpha)+' '+str(N)+' '+str(l)+' '+str(x)+' '+str(y)
				for j in range(2,lr):
					z = int(row[j]);
					args = args+' '+str(z)
				#endfor
			#endif

	#		lr = len(row)
	#		if lr == 2:
	#			z = 0;
	#		else:
	#			z=[];
	#			for j in range(2,lr):
	#				z.append(int(row[j]));
	#			#endfor
	#		#endif
	#		args='./nodebashtest '+dbhost+' '+dbname+' '+tablename+' <NODE> '+pathmatlab+' '+pathds+' '+str(alpha)+' '+str(N)+' '+str(l)+' '+str(x)+' '+str(y)+' '+str(z)
		


			#print 'Adding to queue job %s' % args
			
			queue.put(args)
		#endfor
			
	#endwith
#enddef


def node(nodename):
	try:
		while not stop_threads.is_set():
			try:
				jobs = queue.get(True,0.05)
				args = jobs.replace('<NODE>',nodename)
				#print 'Node %s starts job %s' % (nodename,args)
				try:
					os.system(args)
					queue.task_done()
				#if job fails, requeue it to be done by some other thread
				except Exception as e:
					logging.exception("Error in node thread job");
					print 'Error %s' % e
					jobs = args.replace(nodename,'<NODE>');
					queue.put(jobs);
				print 'Node %s finished job %s' % (nodename,args)
				print 'Queue size is %d' % queue.qsize()
			except Queue.Empty:
		                continue
				
		#endwhile
		print 'Node %s switching off' % node_name
	except Exception as e:
		logging.exception("Error in node thread")
		print 'Error %s' % e
		sys.exit(1)
	#endtry
#enddef

if __name__ == "__main__":
	signal.signal(signal.SIGINT,signal_handler)
	try:
		count=len(sys.argv[1:]);

		if count != 11:
			print 'Wrong nunber of args. Usage:<pathcondlist><nnodes><listnodefile><pathmatlab><pathds><N><l><alpha><dbhost><dbname><tablename>'
			sys.exit()
		#endif

		pathcondlist=sys.argv[1];
		print pathcondlist
		nnodes=int(sys.argv[2]);
		print nnodes
		listnodesf=sys.argv[3];
		print listnodesf
		pathm=sys.argv[4];
		print pathm
		pathds=sys.argv[5];
		print pathds
		N=sys.argv[6];
		print N
		l=sys.argv[7];
		print l
		alpha=sys.argv[8];
		print alpha
		dbhost=sys.argv[9];
		print dbhost
		dbname=sys.argv[10];
		print dbname
		tablename=sys.argv[11];
		print tablename

		#creat queue
		queue = Queue.Queue(nnodes)

		#get the list of nodes on which to run the jobs
		listnodes=[]
		with open(listnodesf,'rb') as filelist:
			for node_name in filelist:
				listnodes.append(node_name.rstrip('\n'))
			#endfor
		#endwith


		node_threads = []

		for node_name in listnodes:
			#print 'Create a thread for node %s' % node_name
			#print(node)
			thread = threading.Thread(target = node, args = (node_name,))
			node_threads.append(thread)
			thread.start()
		#endfor

		#put jobs in the queue
		populateQueue(pathcondlist,pathds,pathm,alpha,N,l)


		#while not queue.empty():
		#	time.sleep(30)
		#endwhile

		#for t in node_threads:
		#try:
		#	t.exit()
		#
		#endfor
		queue.join()
	
		#while not queue.empty():
		#	time.sleep(10)	
		#endwhile

		stop_threads.set()
		print '*************************'
		print '*    STOP THREADS       *'
		print '*************************'

	except Exception as ex:
		logging.exception("In main")
	#endtry
	#os.kill(os.getpid(), 9)
	
#endif
