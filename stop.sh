for i in {11..11};do for j in {1..1};do stop-container $i $j;done;done
for i in {11..11};do rm-bridge $i;done
for i in {11..11};do rm-vlan pc-eth0 $i;done
