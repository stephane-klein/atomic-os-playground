# Atomic OS playground

I developed this playground on Fedora 42.

## CoreOS

Prerequisites:

```
$ sudo dnf install \
    butane \
    coreos-installer \
    libvirt \
    libvirt-daemon-kvm \
    virt-install \
    virt-manager \
    qemu-kvm
```

I follow this officiel documentation to launch [CoreOS](https://notes.sklein.xyz/CoreOS/) instance locally on my Fedora Workstation: [Provisioning Fedora CoreOS on libvirt](https://docs.fedoraproject.org/en-US/fedora-coreos/provisioning-libvirt/).

Fedora CoreOS QEMU image is downloaded by [CoreOS Installer](https://coreos.github.io/coreos-installer/).

```sh
$ ./up-fedora-coreos.sh
$ virsh console coreos-1
...
[stephane@stephane-coreos ~]$ hostnamectl
     Static hostname: stephane-coreos
           Icon name: computer-vm
             Chassis: vm 🖴
          Machine ID: bf0b136db41e44efbf0bd724c0539f53
             Boot ID: 163b4d837a004ac3bb14abc31929d8f7
        AF_VSOCK CID: 1
      Virtualization: kvm
    Operating System: Fedora CoreOS 42.20250901.3.0
         CPE OS Name: cpe:/o:fedoraproject:fedora:42
      OS Support End: Wed 2026-05-13
OS Support Remaining: 7month 2w 4d
              Kernel: Linux 6.15.10-200.fc42.x86_64
        Architecture: x86-64
     Hardware Vendor: QEMU
      Hardware Model: Standard PC _Q35 + ICH9, 2009_
    Firmware Version: 1.17.0-5.fc42
       Firmware Date: Tue 2014-04-01
        Firmware Age: 11y 5month 3w 2d
```

## Teardown

```sh
$ virsh destroy coreos-1
$ virsh undefine coreos-1 --remove-all-storage
```
