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

class MyTopo4( Topo ):
    "Simple topology example."

    def __init__( self,k,bw1,delay1,jitter1,loss1,maxqueuesize1,bw2,delay2,jitter2,loss2,maxqueuesize2,**opts):
        "Create custom topo."

        # Initialize topology
	super(MyTopo4,self).__init__(**opts)
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
	if maxqueuesize1 == 0 & loss1 == 0 & jitter1 == 0:
		self.addLink(host,switch,bw=bw1,delay=delay1)
	elif maxqueuesize1 != 0 & loss1 == 0 & jitter1 == 0:
		self.addLink(host,switch,bw=bw1,delay=delay1,max_queue_size=maxqueuesize1,use_htb=True)
	elif maxqueuesize1 == 0 & loss1 != 0 & jitter1 == 0:
		self.addLink(host,switch,bw=bw1,delay=delay1,loss=loss1)
	elif maxqueuesize1 == 0 & loss1 == 0 & jitter1 != 0:
		self.addLink(host,switch,bw=bw1,delay=delay1,jitter = jitter1)
	elif maxqueuesize1 != 0 & loss1 != 0 & jitter1 == 0:
		self.addLink(host,switch,bw=bw1,delay=delay1,loss=loss1,max_queue_size=maxqueuesize1,use_htb=True)
	elif maxqueuesize1 != 0 & loss1 == 0 & jitter1 != 0:
                self.addLink(host,switch,bw=bw1,delay=delay1,jitter=jitter1,max_queue_size=maxqueuesize1,use_htb=True)
	elif maxqueuesize1 == 0 & loss1 != 0 & jitter1 != 0:
                self.addLink(host,switch,bw=bw1,delay=delay1,loss=loss1,jitter=jitter1)
	elif loss1 != 0 & jitter1 != 0 & maxqueuesize1 != 0:
		self.addLink(host,switch,bw=bw1,delay=delay1,jitter=jitter1,max_queue_size=maxqueuesize1,use_htb = True)
	else:
		self.addLink(host,switch,bw=bw1,delay=delay1,jitter=jitter1,max_queue_size=maxqueuesize1,use_htb = True)
	#endif
	host = self.addHost('h2')
	if maxqueuesize2 == 0 & loss2 == 0 & jitter2 == 0:
                self.addLink(host,switch,bw=bw2,delay=delay2)
        elif maxqueuesize2 != 0 & loss2 == 0 & jitter2 == 0:
                self.addLink(host,switch,bw=bw2,delay=delay2,max_queue_size=maxqueuesize2,use_htb=True)
        elif maxqueuesize2 == 0 & loss2 != 0 & jitter2 == 0:
                self.addLink(host,switch,bw=bw2,delay=delay2,loss=loss2)
        elif maxqueuesize2 == 0 & loss2 == 0 & jitter2 != 0:
                self.addLink(host,switch,bw=bw2,delay=delay2,jitter = jitter2)
        elif maxqueuesize2 != 0 & loss2 != 0 & jitter2 == 0:
                self.addLink(host,switch,bw=bw2,delay=delay2,loss=loss2,max_queue_size=maxqueuesize2,use_htb=True)
        elif maxqueuesize2 != 0 & loss2 == 0 & jitter2 != 0:
                self.addLink(host,switch,bw=bw2,delay=delay2,jitter=jitter2,max_queue_size=maxqueuesize2,use_htb=True)
        elif maxqueuesize2 == 0 & loss2 != 0 & jitter2 != 0:
                self.addLink(host,switch,bw=bw2,delay=delay2,loss=loss2,jitter=jitter2)
        elif loss2 != 0 & jitter2 != 0 & maxqueuesize2 != 0:
                self.addLink(host,switch,bw=bw2,delay=delay2,jitter=jitter2,max_queue_size=maxqueuesize2,use_htb = True)
        else:
                self.addLink(host,switch,bw=bw2,delay=delay2,jitter=jitter2,max_queue_size=maxqueuesize2,use_htb = True)
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
topos = { 'mytopo4': ( lambda k=2,bw1=10,delay1='10ms',jitter1=0,loss1=0,maxqueuesize1=1000,bw2=10,delay2='10ms',jitter2=0,loss2=0,maxqueuesize2=1000: MyTopo4(k,bw1,delay1,jitter1,loss1,maxqueuesize1,bw2,delay2,jitter2,loss2,maxqueuesize2))  }

#if __name__ == '__main__':
#	setLogLevel('info')
#	startServer()
