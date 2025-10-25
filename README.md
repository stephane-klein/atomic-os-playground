# Atomic OS playground

I developed this playground on Fedora 42.

If you would like to better understand how [libostree](https://notes.sklein.xyz/libostree/) works, I recommend studying [`./OSTreeTutorial.md`](./OSTreeTutorial.md).

## CoreOS

### Launch Fedora CoreOS Cloud Image in QEMU

Prerequisites:

```
$ sudo dnf install \
    butane \
    coreos-installer \
    qemu-kvm
```

I follow this officiel documentation to launch [CoreOS](https://notes.sklein.xyz/CoreOS/) Cloud Image instance locally on Qemu VirtualMachine on my Fedora Workstation host: [Provisioning Fedora CoreOS on libvirt](https://docs.fedoraproject.org/en-US/fedora-coreos/provisioning-libvirt/).

Fedora CoreOS QEMU image is downloaded by [CoreOS Installer](https://coreos.github.io/coreos-installer/).

```sh
$ ./up-fedora-coreos.sh
$ socat - UNIX-CONNECT:/tmp/coreos-1-console.sock
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

I can also connect to VM with *ssh*:

```sh
$ ssh-keygen -R "[127.0.0.1]:2222"
$ ssh -p 2222 -o StrictHostKeyChecking=no stephane@127.0.0.1
```

Teardown

```sh
$ systemctl --user stop coreos-1
$ rm disks/*.qcow2
```

You can test to instantiate an old CoreOS release `42.20250526.3.0`:

```sh
$ ./up-old-fedora-coreos.sh
$ ssh -p 2222 -o StrictHostKeyChecking=no stephane@127.0.0.1
```

### Install Fedora CoreOS ISO custom image on QEMU

Go to [`./install-coreos-iso-on-qemu/`](./install-coreos-iso-on-qemu/).

### Creating customized CoreOS ISO

Prerequisites:

```
$ sudo dnf install \
    butane \
    coreos-installer \
    pv
```

```sh
$ ./create-coreos-custom-iso.sh
```

Use [Fedora Media Writer](https://flathub.org/en/apps/org.fedoraproject.MediaWriter) to write `images/fedora-coreos-custom.iso` to USB Key.

Then, boot from the USB stick and you should see the CoreOS installation.
