"""Custom topology example

Two directly connected switches plus a host for each switch:

   host --- switch -- host

Adding the 'topos' dict with a key/value pair to generate our newly defined
topology enables one to pass in '--topo=mytopo' from the command line.
"""
import time
from mininet.topo import Topo
from mininet.net import Mininet
from mininet.log import setLogLevel
from mininet.link import TCLink
from mininet.log import info, error, debug


class MyTopo5( Topo ):
    "Simple topology example."

    def __init__( self,k,bw1a,delay1a,jitter1a,loss1a,maxqueuesize1a,bw1b,delay1b,jitter1b,loss1b,maxqueuesize1b,bw2a,delay2a,jitter2a,loss2a,maxqueuesize2a,bw2b,delay2b,jitter2b,loss2b,maxqueuesize2b,**opts):
        "Create custom topo."

        # Initialize topology
	super(MyTopo5,self).__init__(**opts)
	self.k = k
	self.bw1a = bw1a
	self.delay1a = delay1a
	self.jitter1a = jitter1a
	self.loss1a = loss1a
	self.maxqueuesize1a = maxqueuesize1a
	self.bw1b = bw1b
	self.delay1b = delay1b
	self.jitter1b = jitter1b
	self.loss1b = loss1b
	self.maxqueuesize1b = maxqueuesize1b
	self.bw2a = bw2a
	self.delay2a = delay2a
	self.jitter2a = jitter2a
	self.loss2a = loss2a
	self.maxqueuesize2a = maxqueuesize2a
	self.bw2b = bw2b
	self.delay2b = delay2b
	self.jitter2b = jitter2b
	self.loss2b = loss2b
	self.maxqueuesize2b = maxqueuesize2b

	info('[bw1a: '+str(bw1a)+' ]\n')
	info('[bw1b: '+str(bw1b)+' ]\n')
	info('[delay1a: '+str(delay1a)+' ]\n')
        info('[daley1b: '+str(delay1b)+' ]\n')
	info('[loss1a: '+str(loss1a)+' ]\n')
	info('[loss1b: '+str(loss1b)+' ]\n')
	info('[jitter1a: '+str(jitter1a)+' ]\n')
	info('[jitter1a: '+str(jitter1a)+' ]\n')
	info('[maxqueusize1a: '+str(maxqueuesize1a)+' ]\n')
	info('[maxqueusize1b: '+str(maxqueuesize1b)+' ]\n')
	info('[bw2a: '+str(bw2a)+' ]\n')
	info('[bw2b: '+str(bw1b)+' ]\n')
	info('[delay2a: '+str(delay2a)+' ]\n')
        info('[daley2b: '+str(delay1b)+' ]\n')
	info('[loss2a: '+str(loss2a)+' ]\n')
	info('[loss2b: '+str(loss1b)+' ]\n')
	info('[jitter2a: '+str(jitter2a)+' ]\n')
	info('[jitter2a: '+str(jitter2a)+' ]\n')
	info('[maxqueusize2a: '+str(maxqueuesize2a)+' ]\n')
	info('[maxqueusize2b: '+str(maxqueuesize2b)+' ]\n')

	self.jitter1 = self.jitter1a*self.jitter1b
	self.loss1 = self.loss1a*self.loss1b
	self.maxqueuesize1 = self.maxqueuesize1a*self.maxqueuesize1b
	self.jitter2 = self.jitter2a*self.jitter2b
	self.loss2 = self.loss2a*self.loss2b
	self.maxqueuesize2 = self.maxqueuesize2a*self.maxqueuesize2b

        # Add hosts and switches and links
	switch = self.addSwitch('s1')
	host = self.addHost('h1')
	if self.maxqueuesize1 == 0 & self.loss1 == 0 & self.jitter1 == 0:
		self.addLink(host,switch,bw1=bw1a,bw2=bw1b,delay1=delay1a,delay2=delay1b)
	elif self.maxqueuesize1 != 0 & self.loss1 == 0 & self.jitter1 == 0:
		info('Creating the first link with only queue size not null\n')
		self.addLink(host,switch,bw1=bw1a,bw2=bw1b,delay1=delay1a,delay2=delay1b,max_queue_size1=maxqueuesize1a,max_queue_size2 = maxqueuesize1b,use_htb1=True,use_htb2=True)
	elif self.maxqueuesize1 == 0 & self.loss1 != 0 & self.jitter1 == 0:
		self.addLink(host,switch,bw1=bw1a,bw2=bw1b,delay1=delay1a,delay2=delay1b,loss1=loss1a,loss2=loss1b)
	elif self.maxqueuesize1 == 0 & self.loss1 == 0 & self.jitter1 != 0:
		self.addLink(host,switch,bw1=bw1a,bw2=bw1b,delay1=delay1a,delay2=delay1b,jitter1 = jitter1a,jitter2=jitter1b)
	elif self.maxqueuesize1 != 0 & self.loss1 != 0 & self.jitter1 == 0:
		self.addLink(host,switch,bw=bw1,delay1=delay1a,delay2=delay1b,loss1=loss1a,loss2=loss1b,max_queue_size1=maxqueuesize1a,max_queue_size2=maxqueuesize1b,use_htb1=True,use_htb2=True)
	elif self.maxqueuesize1 != 0 & self.loss1 == 0 & self.jitter1 != 0:
                self.addLink(host,switch,bw1=bw1a,delay1=delay1a,delay2=delay1b,jitter1=jitter1a,jitter2=jitter1b,max_queue_size1=maxqueuesize1a,max_queue_size2=maxqueuesize1b,use_htb1=True,use_htb2=True)
	elif self.maxqueuesize1 == 0 & self.loss1 != 0 & self.jitter1 != 0:
                self.addLink(host,switch,bw1=bw1a,bw2=bw1b,delay1=delay1a,delay2=delay1b,loss1=loss1a,loss2=loss1b,jitter1=jitter1a,jitter2=jitter1b)
	elif self.loss1 != 0 & self.jitter1 != 0 & self.maxqueuesize1 != 0:
		self.addLink(host,switch,bw1=bw1a,bw2=bw1b,delay1=delay1a,delay2=delay1b,jitter1=jitter1a,jitter2=jitter1b,max_queue_size1=maxqueuesize1a,max_queue_size2=maxqueuesize1b,use_htb1 = True,use_htb2 = True)
	else:
		self.addLink(host,switch,bw1=bw1a,bw2=bw1b,delay1=delay1a,delay2=delay1b,jitter1=jitter1a,jitter2=jitter1b,max_queue_size1=maxqueuesize1a,max_queue_size2=maxqueuesize1b,use_htb1 = True,use_htb2 = True)
	#endif
	host = self.addHost('h2')
	if self.maxqueuesize2 == 0 & self.loss2 == 0 & self.jitter2 == 0:
		self.addLink(host,switch,bw1=bw2a,bw2=bw2b,delay1=delay2a,delay2=delay2b)
	elif self.maxqueuesize2 != 0 & self.loss2 == 0 & self.jitter2 == 0:
		self.addLink(host,switch,bw1=bw2a,bw2=bw2b,delay1=delay2a,delay2=delay2b,max_queue_size1=maxqueuesize2a,max_queue_size2 = maxqueuesize2b,use_htb1=True,use_htb2=True)
	elif self.maxqueuesize2 == 0 & self.loss2 != 0 & self.jitter2 == 0:
		self.addLink(host,switch,bw1=bw2a,bw2=bw2b,delay1=delay2a,delay2=delay2b,loss1=loss2a,loss2=loss2b)
	elif self.maxqueuesize2 == 0 & self.loss2 == 0 & self.jitter2 != 0:
		self.addLink(host,switch,bw1=bw2a,bw2=bw2b,delay1=delay2a,delay2=delay2b,jitter1=jitter2a,jitter2=jitter2b)
	elif self.maxqueuesize2 != 0 & self.loss2 != 0 & self.jitter2 == 0:
		self.addLink(host,switch,bw=bw1,delay1=delay2a,delay2=delay2b,loss1=loss2a,loss2=loss2b,max_queue_size1=maxqueuesize2a,max_queue_size2=maxqueuesize2b,use_htb1=True,use_htb2=True)
	elif self.maxqueuesize2 != 0 & self.loss2 == 0 & self.jitter2 != 0:
                self.addLink(host,switch,bw1=bw2a,delay1=delay2a,delay2=delay2b,jitter1=jitter2a,jitter2=jitter2b,max_queue_size1=maxqueuesize2a,max_queue_size2=maxqueuesize2b,use_htb1=True,use_htb2=True)
	elif self.maxqueuesize2 == 0 & self.loss2 != 0 & self.jitter2 != 0:
                self.addLink(host,switch,bw1=bw2a,bw2=bw2b,delay1=delay2a,delay2=delay2b,loss1=loss2a,loss2=loss2b,jitter1=jitter2a,jitter2=jitter2b)
	elif self.loss2 != 0 & self.jitter2 != 0 & self.maxqueuesize2 != 0:
		self.addLink(host,switch,bw1=bw2a,bw2=bw2b,delay1=delay2a,delay2=delay2b,jitter1=jitter2a,jitter2=jitter2b,max_queue_size1=maxqueuesize2a,max_queue_size2=maxqueuesize2b,use_htb1 = True,use_htb2 = True)
	else:
		self.addLink(host,switch,bw1=bw2a,bw2=bw2b,delay1=delay2a,delay2=delay2b,jitter1=jitter2a,jitter2=jitter2b,max_queue_size1=maxqueuesize2a,max_queue_size2=maxqueuesize2b,use_htb1 = True,use_htb2 = True)
	#endif

#def startServer():
#	topo = MyTopo4(k,bw1,delay1,jitter1,loss1,maxqueuesize1,bw2,delay2,jitter2,loss2,maxqueuesize2)
#	net = Mininet(topo=topo,link=TCLink)
#	net.start()
#	print "Start MyTopo4"
#	#starting wireshark on h2
#	h1 = net.get('h1')
#	dates = time.strftime("%d-%m-%y-%H-%M-%S")
#	cname='sudo tcpdump -i h1-eth0 -w /home/mininet/share/pcaptraces.dir/server_client_bw1_'+str(bw1)+'_bw2_'+str(bw2)+'_loss1_'+str(loss1)+'_loss2_'+loss2+'_'+date+'.pcap &'
#	result = h1.cmd(cname)
#	print result	
#
#	#starting http server on h2
#	result = h1.cmd('sudo python -m /home/mininet/mininet/examples/SimpleHTTPServerRandom 1010 &')
#	print result
#	h2 = net.get('h2')
#	result = h2.cmd('/home/mininet/mininet/examples/wgetN.sh 10.0.0.1 1010 10')
#	print result
#	net.stop()
topos = { 'mytopo5': ( lambda k=2,bw1a=10,delay1a='10ms',jitter1a=0,loss1a=0,maxqueuesize1a=1000,bw1b=10,delay1b='10ms',jitter1b=0,loss1b=0,maxqueuesize1b=1000,bw2a=10,delay2a='10ms',jitter2a=0,loss2a=0,maxqueuesize2a=1000,bw2b=10,delay2b='10ms',jitter2b=0,loss2b=0,maxqueuesize2b=1000: MyTopo5(k,bw1a,delay1a,jitter1a,loss1a,maxqueuesize1a,bw1b,delay1b,jitter1b,loss1b,maxqueuesize1b,bw2a,delay2a,jitter2a,loss2a,maxqueuesize2a,bw2b,delay2b,jitter2b,loss2b,maxqueuesize2b))  }

#if __name__ == '__main__':
#	setLogLevel('info')
#	startServer()
