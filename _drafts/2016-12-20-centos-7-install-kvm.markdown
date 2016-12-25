---
layout:     post
title:      "CentOS 7 安装配置 KVM"
subtitle:   ""
date:       2016-12-20 17:04:00 +08:00
author:     "Y.M. Xu"
header-img: "img/bg/post-2016-lake-wire.png"
catalog: true
tags:
    - Linux
    - CentOS
    - Virtulization
    - KVM

---

[KVM使用NAT联网并为VM配置iptables端口转发](http://www.ilanni.com/?p=7016)

[Install and use CentOS 7 or RHEL 7 as KVM virtualization host](http://jensd.be/207/linux/install-and-use-centos-7-as-kvm-virtualization-host)

```bash
$ egrep -c '(vmx|svm)' /proc/cpuinfo
```

```bash
$ sudo yum install kvm virt-manager libvirt virt-install qemu-kvm
```

```bash
$ lsmod|grep kvm
kvm_intel 138567 0
kvm 441119 1 kvm_intel
```

```bash
$ virsh net-list
 Name                 State      Autostart     Persistent
----------------------------------------------------------
 default              active     yes           yes
```

```bash
$ sudo virsh -c qemu:///system list
 Id    Name                           State
----------------------------------------------------
```

```bash
$ qemu-img create -f qcow2 vDisk/win7.img 64G
```

```bash
$ sudo virt-install --connect qemu:///system --name=vmwin7 --os-type windows --os-variant win7 --memory=4096 --vcpus=4 --disk path=/var/store/vDisk/win7.img,format=qcow2,bus=ide --graphics vnc,listen=0.0.0.0,port=5991  --network=network:default --accelerate --hvm --cdrom /var/cloud/downloads/Win_7_ULTIMATE_32_with_sp1.iso
```

```bash
$ sudo virt-install --connect qemu:///system --name=centest --os-type linux --os-variant rhel7 --memory=4096 --vcpus=4 --disk path=/var/store/vDisk/centest.img,format=qcow2,bus=ide --graphics vnc,listen=0.0.0.0,port=5992  --network=network:default --cdrom /var/cloud/downloads/CentOS-7-x86_64-LiveGNOME-1611.iso
```

