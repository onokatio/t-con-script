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

# rm-vlan($interface,$vlannum);
function rm-vlan(){
	vconfig rem $1.$2
}
# rm-bridge($brnum)
function rm-bridge(){
	brctl delbr t_br$1
}
# stop-container($teamnum,$qnumber)
function stop-container(){
	lxc-stop -n t_vm$1-$2
}

for i in {11..11};do for j in {1..1};do stop-container $i $j;done;done
for i in {11..11};do rm-bridge $i;done
for i in {11..11};do rm-vlan pc-eth0 $i;done
