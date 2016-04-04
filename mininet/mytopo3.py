"""Custom topology example

Two directly connected switches plus a host for each switch:

   host --- switch -- host

Adding the 'topos' dict with a key/value pair to generate our newly defined
topology enables one to pass in '--topo=mytopo' from the command line.
"""

from mininet.topo import Topo
from mininet.net import Mininet
from mininet.log import setLogLevel
from mininet.link import TCLink

class MyTopo3( Topo ):
    "Simple topology example."

    def __init__( self,k,bw1,delay1,jitter1,loss1,maxqueuesize1,bw2,delay2,jitter2,loss2,maxqueuesize2,**opts):
        "Create custom topo."

        # Initialize topology
	super(MyTopo3,self).__init__(**opts)
	self.k = k
	self.bw1 = bw1
	self.delay1 = delay1
	self.jitter1 = jitter1
	self.loss1 = loss1
	self.maxqueuesize1 = maxqueuesize1	
	self.bw2 = bw2
	self.delay2 = delay2
	self.jitter2 = jitter2
	self.loss2 = loss2
	self.maxqueuesize2 = maxqueuesize2	

        # Add hosts and switches and links
	switch = self.addSwitch('s1')
	host = self.addHost('h1')
	if loss1 == 0:
		self.addLink(host,switch,bw=bw1,delay=delay1,jitter=jitter1,max_queue_size=maxqueuesize1,use_htb = True)
	else:
		self.addLink(host,switch,bw=bw1,delay=delay1,jitter=jitter1,loss=loss1,max_queue_size=maxqueuesize1,use_htb=True)
	#endif
	host = self.addHost('h2')
	if loss2 == 0:
		self.addLink(host,switch,bw=bw2,delay=delay2,jitter=jitter2,max_queue_size=maxqueuesize2,use_htb = True)
	else:
		self.addLink(host,switch,bw=bw2,delay=delay2,jitter=jitter2,loss=loss2,max_queue_size=maxqueuesize2,use_htb = True)
	#endif

#def startServer():
#	topo = MyTopo1()
#	net = Mininet(topo=topo,link=TCLink)
#	net.start()
#	print "Start MyTopo1"
#	#starting wireshark on h2
#	h2 = net.get('h2')
#	result = h2.cmd('wireshark &')
#	print result	
#
#	#starting http server on h2
#	result = h2.cmd('python -m /home/mininet/mininet/examples/SimpleHTTPServerRandom 80 &')
#	print result

topos = { 'mytopo3': ( lambda k=2,bw1=10,delay1='10ms',jitter1=0,loss1=0,maxqueuesize1=1000,bw2=10,delay2='10ms',jitter2=0,loss2=0,maxqueuesize2=1000: MyTopo3(k,bw1,delay1,jitter1,loss1,maxqueuesize1,bw2,delay2,jitter2,loss2,maxqueuesize2))  }

#if __name__ == '__main__':
#	setLogLevel('info')
#	startServer()
