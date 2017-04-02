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

usage(){
cat <<_EOL_
Usage:
	$0 チーム数 問題数 物理NIC [管理用NIC]

	チーム数、問題数は数値にしてください。
	物理NICは存在する物理的なNICのインターフェース名を指定してください。
	参加者用ネットワークと管理用ネットワークはVLANで隔離されますが、さらなる安全性を求める場合は管理用のNICを分けることができます。

	チーム番号は11から始まり、26まで作成できます。つまり最大16チームが同時に参加できます。
	また各チームには、参加者PCやチーム用の問題VMに接続されているVLANが1つ与えられます。
	その場合VLAN番号はチーム番号になります。つまりVLAN番号は11~26までチームVLANに使用されます。

VLAN構成(管理用NICを分けた場合も同じ)
	VLAN1	管理用VLAN。すべてのコンテナやコンピュートノード自体にアクセスできる。
	VLAN11-26 チームごとのVLAN。

IPアドレス割当

	VLAN1:
		10.7.0.1 演算ノード。つまりはこのシェルスクリプトを実行するノード。
		10.7.<チーム番号>.<問題番号> 192.168.<チーム番号>.<問題番号>のVMにアクセスできる。

	VLAN11-26:
		192.168.<チーム番号>.<問題番号> その問題のチーム専用のVM
		192.168.<チーム番号>.200 ~
	 		192.168.<チーム番号>.253	チーム参加者の手元のパソコンに割り振られる
		192.168.<チーム番号>.254 デフォルトゲートウェイ。外のインターネットにつなげるようになっている。

	各コンテナには、eth0とman0の2つのNICが構成されている。
	eth0はチームごとのVLANに接続、man0は管理用のVLANに接続している。


_EOL_
}
usage

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


#for i in {11..11};do make-vlan pc-eth0 $i;done
#for i in {11..11};do make-bridge $i;done
#for i in {11..11};do add-vnic-to-bridge pc-eth0 $i;done
#for i in {11..11};do
#	for j in {1..1};do
#		make-container ubuntu $i $j && configure-container-vlan $i $j
#	done
#done
