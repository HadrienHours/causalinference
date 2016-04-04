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

class MyTopo1( Topo ):
    "Simple topology example."

    def __init__( self,k=2,bw1=10,delay1='10ms',jitter1=0,loss1=0,maxqueuesize1=1000,bw2=10,delay2='10ms',jitter2=0,loss2=0,maxqueuesize2=1000):
        "Create custom topo."

        # Initialize topology
        Topo.__init__( self )
	

        # Add hosts and switches and links
	switch = self.addSwitch('s1')
	host = self.addHost('h1')
	self.addLink(host,switch,bw=bw1,delay=delay1,jitter=jitter1,loss=loss1,maxqueuesize=maxqueuesize1)
	host = self.addHost('h2')
	self.addLink(host,switch,bw=bw2,delay=delay2,jitter=jitter2,loss=loss2,maxqueuesize=maxqueuesize2)

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

topos = { 'mytopo1': ( lambda: MyTopo1() ) }

#if __name__ == '__main__':
#	setLogLevel('info')
#	startServer()
