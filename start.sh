#!/bin/bash
# make by onokatio and many thanks.

# naming rule
#
# vlan = t_vlan(team number)
#	bridge = t_br0(team number)
#	container = t_vm(team number)(question number)
#
# ipaddres = 192.168.team.question
#
# t_vlan11 -- t_br11 -- t_vm0, t_vm1, ...
# t_vlan12 -- t_br12 -- t_vm0, t_vm1, ...
#  ...


QUESTION_NUM=10
TEAM_NUM=10

# make-vlan($interface,$vlannum);
function make-vlan(){
	vconfig add $1 $2
}
# rm-vlan($interface,$vlannum);
function rm-vlan(){
	vconfig rem $1.$2
}

# make-bridge($brnum)
function make-bridge(){
	brctl addbr t_br$1
}
# rm-bridge($brnum)
function rm-bridge(){
	brctl delbr t_br$1
}
# add-vnic-to-bridge($vlan-parent-interface,$vlannum)
function add-vnic-to-bridge(){
	brctl addif t_br$2 $1.$2
}

# make-container($image,$teamnum,$qnumber)
function make-container(){
	lxc-create -t $1 -n t_vm$2-$3
	lxc-start -n t_vm$2-$3 -d
}
# stop-container($teamnum,$qnumber)
function stop-container(){
	lxc-stop -n t_vm$1-$2
}
# configure-container-vlan($teamnum,$qnumber)
function configure-container-vlan(){
	sed -E 's/lxc.network.link = ([A-Za-z_0-9])/lxc.network.link = t_br/' /var/lib/lxc/t_br$1/config > tmp
	mv tmp /var/lib/lxc/t_vm$1-$2/config
}


for i in {11..11};do make-vlan pc-eth0 $i;done
for i in {11..11};do make-bridge $i;done
for i in {11..11};do add-vnic-to-bridge pc-eth0 $i;done
for i in {11..11};do
	for j in {1..1};do
		make-container ubuntu $i $j && configure-container-vlan $i $j
	done
done
