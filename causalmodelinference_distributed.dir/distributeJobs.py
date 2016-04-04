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
import argparse
queue = None

verbose = 2

stop_threads = threading.Event()

def signal_handler(sig,frame):
  if sig -- signal.SIGINT:
    os.kill(os.getpid(),9)
    sys.exit(0)
#endif
#enddef


def populateQueue(pathds,pathlistindep,pathresultsdir,nreps,subs,alpha):
  global queue
  with open(pathlistindep,'r') as csvfile:
    filereader=csv.reader(csvfile,delimiter=',')
    next(filereader,None)
    for row in filereader:
      x = row[0]
      y = row[1]
      lr=len(row)
      if lr == 2:
        args='./indep_node_test '+pathds+' '+pathresultsdir+' '+str(x)+' '+str(y)+' '+str(nreps)+' '+str(subs)+' '+str(alpha)+' <NODE> '
      else:
        args='./indep_node_test '+pathds+' '+pathresultsdir+' '+str(x)+' '+str(y)
        for ii in range(2,lr):
          args=args+' '+str(row[ii])
        args=args+' '+str(nreps)+' '+str(subs)+' '+str(alpha)+' <NODE> '
      if verbose > 1:
        print 'Adding the following task to the queue %s\n'% args
      queue.put(args)

def node(nodename):
  global queue
  try:
    while not stop_threads.is_set():
      try:
        jobs = queue.get(True,5)
        args = jobs.replace('<NODE>',nodename)
        try:
          if verbose > 1:
            print 'Node %s starts the job: %s'%(nodename,args)
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
    print 'Node %s switching off' % nodename
  except Exception as e:
    logging.exception("Error in node thread")
    print 'Error %s' % e
    sys.exit(1)
#endtry
#enddef

def parse_args():
  parser = argparse.ArgumentParser()
  parser.add_argument("pathds", type = str, help = "Path to csvfile containing the dataset")
  parser.add_argument("listindeptotest", type = str, help = "path to file of the list of indepedences to test")
  parser.add_argument("listmachines", type = str, help = "File with list of machines to execute the different tests")
  parser.add_argument("resdirpath", type = str, help = "path to directory to store results")
  parser.add_argument("nrep", type = int, help = "Number of subtest in the independence test")
  parser.add_argument("subs", type = int, help = "Size of subdataset for the subtests")
  parser.add_argument("alpha",type=float, help = "Significance level to use in the subtests")
  return parser.parse_args()

def main(args):
  global queue
  #Get input
  pathds=args.pathds
  pathlistindep=args.listindeptotest
  listmachines=args.listmachines
  pathresultsdir=args.resdirpath
  nreps=int(args.nrep)
  subs=int(args.subs)
  alpha=float(args.alpha)

  #Start signal handler to stp threads
  signal.signal(signal.SIGINT,signal_handler)
  
  try:
    #create threads
    listmac = []
    with open(listmachines,'r') as file:
      for line in file:
        listmac.append(line.strip())
    nnodes=len(listmac)

    if verbose > 2:
      print '%d workers available' % nnodes
    #Create queue
    queue = Queue.Queue(nnodes)
    #queue = Queue.Queue() #infinite

    if verbose > 1:
      print 'Queue created'

    node_threads = []
    for node_name in listmac:
      print 'Thread for node %s about to be started\n' %node_name
      thread = threading.Thread(target = node, args = (node_name,))
      node_threads.append(thread)
      thread.start()

    #put jobs in the queue
    populateQueue(pathds,pathlistindep,pathresultsdir,nreps,subs,alpha)

    if verbose > 0:
      print 'Queue was created and populated with %d tasks queued' % queue.qsize()

    #Block the queue
    queue.join()
  
    stop_threads.set()
    print '*************************'
    print '*    STOP THREADS       *'
    print '*************************'


  except Exception as ex:
    logging.exception("Error in main")


if __name__ == "__main__":
  main(parse_args())
