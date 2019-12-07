set ns [new Simulator]

set nf [open out.nam w]
$ns namtrace-all $nf

set tf [open out.tr w]
$ns trace-all $tf

proc finish {} {
global ns nf tf
$ns flush-trace
close $tf
close $nf
exec nam out.nam &
exit 0
}

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
$n0 set label "ping0"
$n1 set label "ping1"
$n2 set label "r1"
$n3 set label "r2"
$n4 set label "ping4"
$n5 set label "ping5"
$ns color 1 "red"
$ns color 2 "green"
$ns color 2 "blue"
$ns color 3 "orange"

$ns duplex-link $n0 $n2 0.4Mb 10ms DropTail
$ns duplex-link $n1 $n2 1Mb 10ms DropTail
$ns duplex-link $n2 $n3 0.5Mb 100ms DropTail
$ns duplex-link $n3 $n4 1Mb 10ms DropTail
$ns duplex-link $n3 $n5 1Mb 10ms DropTail

$ns duplex-link-op $n0 $n2 orient right-down
$ns duplex-link-op $n1 $n2 orient right-up
$ns duplex-link-op $n2 $n3 orient right
$ns duplex-link-op $n3 $n4 orient right-up
$ns duplex-link-op $n3 $n5 orient right-down

set ping0 [new Agent/Ping]
$ns attach-agent $n0 $ping0

set ping1 [new Agent/Ping]
$ns attach-agent $n1 $ping1

set ping4 [new Agent/Ping]
$ns attach-agent $n4 $ping4

set ping5 [new Agent/Ping]
$ns attach-agent $n5 $ping5

$ns connect $ping0 $ping4
$ns connect $ping1 $ping5

proc sendPingPacket {} {
global ns ping0 ping1
set now [$ns now]
set intervalTime 0.001
$ns at [expr $now+$intervalTime] "$ping0 send"
$ns at [expr $now+$intervalTime] "$ping1 send"
$ns at [expr $now+$intervalTime] "sendPingPacket"
}

Agent/Ping instproc recv {from rtt} {
$self instvar node_
puts "The node with id [$node_ id] recieved an ACK from $from with a rtt of $rtt ms"
}

$ping0 set class_ 1
$ping1 set class_ 2
$ping4 set class_ 3
$ping5 set class_ 4

$ns at 0.0 "sendPingPacket"
$ns at 2.5 "finish"
$ns run
