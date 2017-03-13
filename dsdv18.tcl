# wrls1.tcl
# A 3-node example for ad-hoc simulation with DSDV

# Define options
set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         20                         ;# max packet in ifq
set val(nn)             50                          ;# number of mobilenodes
set val(rp)             DSDV                       ;# routing protocol
set val(x)              500   			   ;# X dimension of topography
set val(y)              400   			   ;# Y dimension of topography  
set val(stop)		150			   ;# time of simulation end

set ns		  [new Simulator]
set tracefd       [open simple-dsdv.tr w]
set windowVsTime2 [open win.tr w] 
set namtrace      [open simwrls.nam w]    

$ns trace-all $tracefd
$ns use-newtrace 
$ns namtrace-all-wireless $namtrace $val(x) $val(y)

# set up topography object
set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)

#
#  Create nn mobilenodes [$val(nn)] and attach them to the channel. 
#

# configure the nodes
        $ns node-config -adhocRouting $val(rp) \
			 -llType $val(ll) \
			 -macType $val(mac) \
			 -ifqType $val(ifq) \
			 -ifqLen $val(ifqlen) \
			 -antType $val(ant) \
			 -propType $val(prop) \
			 -phyType $val(netif) \
			 -channelType $val(chan) \
			 -topoInstance $topo \
			 -agentTrace ON \
			 -routerTrace ON \
			 -macTrace OFF \
			 -movementTrace ON
	

# Provide initial location of mobilenodes		 
	for {set i 0} {$i < $val(nn) } { incr i } {
		set node_($i) [$ns node]
 		$node_($i) set X_ [ expr 10+round(rand()*480) ]
        	$node_($i) set Y_ [ expr 10+round(rand()*380) ]
        	$node_($i) set Z_ 0.0	
	}
   
for {set i 0} {$i < $val(nn) } { incr i } {
        $ns at [ expr 15+round(rand()*60) ] "$node_($i) setdest [ expr 10+round(rand()*480) ] [ expr 10+round(rand()*380) ] [ expr 2+round(rand()*15) ]"
        
    }

# Generation of movements
# $ns at 10.0 "$node_(0) setdest 250.0 250.0 3.0"
# $ns at 15.0 "$node_(1) setdest 45.0 285.0 5.0"
# $ns at 70.0 "$node_(2) setdest 480.0 300.0 5.0"
# $ns at 20.0 "$node_(3) setdest 200.0 200.0 5.0"
# $ns at 25.0 "$node_(4) setdest 50.0 50.0 10.0"
# $ns at 60.0 "$node_(5) setdest 150.0 70.0 2.0"
# $ns at 90.0 "$node_(6) setdest 380.0 150.0 8.0"
# $ns at 42.0 "$node_(7) setdest 200.0 100.0 15.0"
# $ns at 55.0 "$node_(8) setdest 50.0 275.0 5.0"
# $ns at 19.0 "$node_(9) setdest 250.0 250.0 7.0"
# $ns at 90.0 "$node_(10) setdest 150.0 150.0 20.0"


# Set a TCP connection between node_(0) and node_(8)
set tcp [new Agent/TCP/Newreno]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns attach-agent $node_(0) $tcp
$ns attach-agent $node_(8) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 10.0 "$ftp start" 

# Set a TCP connection between node_(2) and node_(8)
set tcp [new Agent/TCP/Newreno]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns attach-agent $node_(2) $tcp
$ns attach-agent $node_(8) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 10.0 "$ftp start"

# Printing the window size
proc plotWindow {tcpSource file} {
global ns
set time 0.01
set now [$ns now]
set cwnd [$tcpSource set cwnd_]
puts $file "$now $cwnd"
$ns at [expr $now+$time] "plotWindow $tcpSource $file" }
$ns at 10.1 "plotWindow $tcp $windowVsTime2"

 

# Define node initial position in nam
for {set i 0} {$i < $val(nn)} { incr i } {
# 30 defines the node size for nam
$ns initial_node_pos $node_($i) 30
}

# Telling nodes when the simulation ends
for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "$node_($i) reset";
}

# ending nam and the simulation 
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "stop"
$ns at 150.01 "puts \"end simulation\" ; $ns halt"
proc stop {} {
    global ns tracefd namtrace
    $ns flush-trace
    close $tracefd
    close $namtrace
    exec nam simwrls.nam &
}

$ns run

