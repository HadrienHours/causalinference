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

class MyTopo2RX( Topo ):
    "2 Switch 4 nodes topology"

    def __init__( self,k,bw1,delay1,jitter1,loss1,maxqueuesize1,bw2,delay2,jitter2,loss2,maxqueuesize2,bw3,delay3,jitter3,loss3,maxqueuesize3,bw4,delay4,jitter4,loss4,maxqueuesize4,bw5,delay5,jitter5,loss5,maxqueuesize5,**opts):
        "Create custom topo."

        # Initialize topology
        super(MyTopo2RX,self).__init__(**opts)
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
        self.bw3 = bw3
        self.delay3 = delay3
        self.jitter3 = jitter3
        self.loss3 = loss3
        self.maxqueuesize3 = maxqueuesize3
        self.bw4 = bw4
        self.delay4 = delay4
        self.jitter4 = jitter4
        self.loss4 = loss4
        self.maxqueuesize4 = maxqueuesize4
        self.bw5 = bw5
        self.delay5 = delay5
        self.jitter5 = jitter5
        self.loss5 = loss5
        self.maxqueuesize5 = maxqueuesize5

        # Add hosts and switches and links
        switch1 = self.addSwitch('s1')
        switch2 = self.addSwitch('s2')
        host1 = self.addHost('h1')
        if maxqueuesize1 == 0 & loss1 == 0 & jitter1 == 0:
            self.addLink(host1,switch1,bw=bw1,delay=delay1)
        elif maxqueuesize1 != 0 & loss1 == 0 & jitter1 == 0:
            self.addLink(host1,switch1,bw=bw1,delay=delay1,max_queue_size=maxqueuesize1,use_htb=True)
        elif maxqueuesize1 == 0 & loss1 != 0 & jitter1 == 0:
            self.addLink(host1,switch1,bw=bw1,delay=delay1,loss=loss1)
        elif maxqueuesize1 == 0 & loss1 == 0 & jitter1 != 0:
            self.addLink(host1,switch1,bw=bw1,delay=delay1,jitter = jitter1)
        elif maxqueuesize1 != 0 & loss1 != 0 & jitter1 == 0:
            self.addLink(host1,switch1,bw=bw1,delay=delay1,loss=loss1,max_queue_size=maxqueuesize1,use_htb=True)
        elif maxqueuesize1 != 0 & loss1 == 0 & jitter1 != 0:
            self.addLink(host1,switch1,bw=bw1,delay=delay1,jitter=jitter1,max_queue_size=maxqueuesize1,use_htb=True)
        elif maxqueuesize1 == 0 & loss1 != 0 & jitter1 != 0:
            self.addLink(host1,switch1,bw=bw1,delay=delay1,loss=loss1,jitter=jitter1)
        elif loss1 != 0 & jitter1 != 0 & maxqueuesize1 != 0:
            self.addLink(host1,switch1,bw=bw1,delay=delay1,jitter=jitter1,max_queue_size=maxqueuesize1,use_htb = True)
        else:
            self.addLink(host,switch1,bw=bw1,delay=delay1,jitter=jitter1,max_queue_size=maxqueuesize1,use_htb = True)
        #endif
        host2 = self.addHost('h2')
        if maxqueuesize2 == 0 & loss2 == 0 & jitter2 == 0:
            self.addLink(host2,switch2,bw=bw2,delay=delay2)
        elif maxqueuesize2 != 0 & loss2 == 0 & jitter2 == 0:
            self.addLink(host2,switch2,bw=bw2,delay=delay2,max_queue_size=maxqueuesize2,use_htb=True)
        elif maxqueuesize2 == 0 & loss2 != 0 & jitter2 == 0:
            self.addLink(host2,switch2,bw=bw2,delay=delay2,loss=loss2)
        elif maxqueuesize2 == 0 & loss2 == 0 & jitter2 != 0:
            self.addLink(host2,switch2,bw=bw2,delay=delay2,jitter = jitter2)
        elif maxqueuesize2 != 0 & loss2 != 0 & jitter2 == 0:
            self.addLink(host2,switch2,bw=bw2,delay=delay2,loss=loss2,max_queue_size=maxqueuesize2,use_htb=True)
        elif maxqueuesize2 != 0 & loss2 == 0 & jitter2 != 0:
            self.addLink(host2,switch2,bw=bw2,delay=delay2,jitter=jitter2,max_queue_size=maxqueuesize2,use_htb=True)
        elif maxqueuesize2 == 0 & loss2 != 0 & jitter2 != 0:
            self.addLink(host2,switch2,bw=bw2,delay=delay2,loss=loss2,jitter=jitter2)
        elif loss2 != 0 & jitter2 != 0 & maxqueuesize2 != 0:
            self.addLink(host2,switch2,bw=bw2,delay=delay2,jitter=jitter2,max_queue_size=maxqueuesize2,use_htb = True)
        else:
            self.addLink(host2,switch2,bw=bw2,delay=delay2,jitter=jitter2,max_queue_size=maxqueuesize2,use_htb = True)
        #endif
        host3 = self.addHost('h3')
        if maxqueuesize3 == 0 & loss3 == 0 & jitter3 == 0:
            self.addLink(host3,switch1,bw=bw3,delay=delay3)
        elif maxqueuesize3 != 0 & loss3 == 0 & jitter3 == 0:
            self.addLink(host3,switch1,bw=bw3,delay=delay3,max_queue_size=maxqueuesize3,use_htb=True)
        elif maxqueuesize3 == 0 & loss3 != 0 & jitter3 == 0:
            self.addLink(host3,switch1,bw=bw3,delay=delay3,loss=loss3)
        elif maxqueuesize3 == 0 & loss3 == 0 & jitter3 != 0:
            self.addLink(host3,switch1,bw=bw3,delay=delay3,jitter = jitter3)
        elif maxqueuesize3 != 0 & loss3 != 0 & jitter3 == 0:
            self.addLink(host3,switch1,bw=bw3,delay=delay3,loss=loss3,max_queue_size=maxqueuesize3,use_htb=True)
        elif maxqueuesize3 != 0 & loss3 == 0 & jitter3 != 0:
            self.addLink(host3,switch1,bw=bw3,delay=delay3,jitter=jitter3,max_queue_size=maxqueuesize3,use_htb=True)
        elif maxqueuesize3 == 0 & loss3 != 0 & jitter3 != 0:
            self.addLink(host3,switch1,bw=bw3,delay=delay3,loss=loss3,jitter=jitter3)
        elif loss3 != 0 & jitter3 != 0 & maxqueuesize3 != 0:
            self.addLink(host3,switch1,bw=bw3,delay=delay3,jitter=jitter3,max_queue_size=maxqueuesize3,use_htb = True)
        else:
            self.addLink(host,switch1,bw=bw3,delay=delay3,jitter=jitter3,max_queue_size=maxqueuesize3,use_htb = True)
        #endif
        host4 = self.addHost('h4')
        if maxqueuesize4 == 0 & loss4 == 0 & jitter4 == 0:
            self.addLink(host4,switch2,bw=bw4,delay=delay4)
        elif maxqueuesize4 != 0 & loss4 == 0 & jitter4 == 0:
            self.addLink(host4,switch2,bw=bw4,delay=delay4,max_queue_size=maxqueuesize4,use_htb=True)
        elif maxqueuesize4 == 0 & loss4 != 0 & jitter4 == 0:
            self.addLink(host4,switch2,bw=bw4,delay=delay4,loss=loss4)
        elif maxqueuesize4 == 0 & loss4 == 0 & jitter4 != 0:
            self.addLink(host4,switch2,bw=bw4,delay=delay4,jitter = jitter4)
        elif maxqueuesize4 != 0 & loss4 != 0 & jitter4 == 0:
            self.addLink(host4,switch2,bw=bw4,delay=delay4,loss=loss4,max_queue_size=maxqueuesize4,use_htb=True)
        elif maxqueuesize4 != 0 & loss4 == 0 & jitter4 != 0:
            self.addLink(host4,switch2,bw=bw4,delay=delay4,jitter=jitter4,max_queue_size=maxqueuesize4,use_htb=True)
        elif maxqueuesize4 == 0 & loss4 != 0 & jitter4 != 0:
            self.addLink(host4,switch2,bw=bw4,delay=delay4,loss=loss4,jitter=jitter4)
        elif loss4 != 0 & jitter4 != 0 & maxqueuesize4 != 0:
            self.addLink(host4,switch2,bw=bw4,delay=delay4,jitter=jitter4,max_queue_size=maxqueuesize4,use_htb = True)
        else:
            self.addLink(host4,switch2,bw=bw4,delay=delay4,jitter=jitter4,max_queue_size=maxqueuesize4,use_htb = True)
        #endif
        if maxqueuesize5 == 0 & loss5 == 0 & jitter5 == 0:
            self.addLink(switch1,switch2,bw=bw5,delay=delay5)
        elif maxqueuesize5 != 0 & loss5 == 0 & jitter5 == 0:
            self.addLink(switch1,switch2,bw=bw5,delay=delay5,max_queue_size=maxqueuesize5,use_htb=True)
        elif maxqueuesize5 == 0 & loss5 != 0 & jitter5 == 0:
            self.addLink(switch1,switch2,bw=bw5,delay=delay5,loss=loss5)
        elif maxqueuesize5 == 0 & loss5 == 0 & jitter5 != 0:
            self.addLink(switch1,switch2,bw=bw5,delay=delay5,jitter = jitter5)
        elif maxqueuesize5 != 0 & loss5 != 0 & jitter5 == 0:
            self.addLink(switch1,switch2,bw=bw5,delay=delay5,loss=loss5,max_queue_size=maxqueuesize5,use_htb=True)
        elif maxqueuesize5 != 0 & loss5 == 0 & jitter5 != 0:
            self.addLink(switch1,switch2,bw=bw5,delay=delay5,jitter=jitter5,max_queue_size=maxqueuesize5,use_htb=True)
        elif maxqueuesize5 == 0 & loss5 != 0 & jitter5 != 0:
            self.addLink(switch1,switch2,bw=bw5,delay=delay5,loss=loss5,jitter=jitter5)
        elif loss5 != 0 & jitter5 != 0 & maxqueuesize5 != 0:
            self.addLink(switch1,switch2,bw=bw5,delay=delay5,jitter=jitter5,max_queue_size=maxqueuesize5,use_htb = True)
        else:
            self.addLink(switch1,switch2,bw=bw5,delay=delay5,jitter=jitter5,max_queue_size=maxqueuesize5,use_htb = True)
        #endif


topos = { 'mytopo2RX': ( lambda k=6,bw1=10,delay1='10ms',jitter1=0,loss1=0,maxqueuesize1=1000,bw2=10,delay2='10ms',jitter2=0,loss2=0,maxqueuesize2=1000,bw3=10,delay3='10ms',jitter3=0,loss3=0,maxqueuesize3=1000,bw4=10,delay4='10ms',jitter4=0,loss4=0,maxqueuesize4=1000,bw5=10,delay5='10ms',jitter5=0,loss5=0,maxqueuesize5=1000: MyTopo2RX(k,bw1,delay1,jitter1,loss1,maxqueuesize1,bw2,delay2,jitter2,loss2,maxqueuesize2,bw3,delay3,jitter3,loss3,maxqueuesize3,bw4,delay4,jitter4,loss4,maxqueuesize4,bw5,delay5,jitter5,loss5,maxqueuesize5)) }
