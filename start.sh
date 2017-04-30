#!/bin/bash

# create-vlan($interface,$vlannum);
function create-vlan(){
	vconfig add $1 $2
}
# destory-vlan($interface,$vlannum);
function destory-vlan(){
	vconfig rem $1.$2
}
# create-bridge($brname)
function create-bridge(){
	ovs-vsctl add-br $1
}
# destroy-bridge($brname)
function destory-bridge(){
	ovs-vsctl del-br $1
}
# add-vnic-to-bridge($br,$vlan-parent-interface,$vlannum)
function add-vnic-to-bridge(){
	ovs-vsctl add-port $1 $2.$3
}
# del-vnic-to-bridge($br,$vlan-parent-interface,$vlannum)
function del-vnic-to-bridge(){
	ovs-vsctl del-port $1 $2.$3
}
# create-container($image,$name)
function create-container(){
	lxc init $1 $2
}
# destory-container($name)
function destory-container(){
	lxc delete $1
}
# add-br-to-container($brname,$container,$interface)
function add-br-to-container(){
	lxc network attach $1 $2 $3
}
# start-container($name){
start-container(){
	lxc start $1
}
# stop-container($name){
stop-container(){
	lxc stop $1
}

echo 1
create-vlan pc-eth0 12
echo 1
create-bridge team12-br
echo 1
add-vnic-to-bridge team12-br pc-eth0 12
echo 1
create-container ubuntu:zesty q12-1
echo 1
add-br-to-container team12-br q12-1 eth0
echo 1
start-container q12-1
echo 1
lxc exec q12-1 -- ip addr add 192.168.12.1/24 dev eth0

lxc exec q12-1 -- /bin/bash
echo 1
stop-container q12-1
echo 1
destory-container q12-1
echo 1
del-vnic-to-bridge team12-br pc-eth0 12
echo 1
destory-bridge team12-br
echo 1
destory-vlan pc-eth0 12
echo 1
