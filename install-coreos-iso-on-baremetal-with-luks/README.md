# Install Fedora CoreOS on Baremetal with LUKS and TPM2

I use this playground to build a Fedora Core OS ISO with LUKS and TPM2 support for bare-metal installation.

Resources: https://docs.fedoraproject.org/en-US/fedora-coreos/bare-metal/

**Prerequisites**

In this playground, I use [Oils](https://oils.pub/). To install this shell, follow instructions: <https://github.com/oils-for-unix/oils/wiki/Oils-Deployments>.

Next:

```
$ sudo dnf install \
    butane \
    coreos-installer
```

**Getting started**

Download the stable `x86_64` metal ISO, generate the Ignition configuration, and build the custom ISO:


```sh
$ ./create-custom-iso.sh
```

Write ISO to USB key with:

```
$ ./write-to-usb-interactive.sh
=== Fedora USB Writer ===
ISO: images/fedora-coreos-custom-for-baremetal.iso

Available USB drives:
  1) /dev/sda (14,5G Generic  STORAGE DEVICE)

Select drive [1-1]: 1
Unmounting partitions...
Writing ISO to /dev/sda...
1010827264 octets (1,0 GB, 964 MiB) copiés, 145 s, 7,0 MB/s
15+1 enregistrements lus
15+1 enregistrements écrits
1010827264 octets (1,0 GB, 964 MiB) copiés, 145,915 s, 6,9 MB/s

✓ Done! USB drive is ready.
```

Next:

- Configure BIOS to boot from USB, plug the USB key, and reboot
- Wait for automated installation to complete (system powers off when done)
- Remove USB key and set NVMe as primary boot device in BIOS
- Reboot - TPM2 unlocks the disk automatically

I can observe that LUKS (encryption) is indeed enabled for `/var`:

```
$ ssh stephane@192.168.1.91
stephane@stephane-coreos:~$ lsblk -f
NAME        FSTYPE      FSVER LABEL      UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
nvme0n1
├─nvme0n1p1
├─nvme0n1p2 vfat        FAT16 EFI-SYSTEM 7B77-95E7
├─nvme0n1p3 ext4        1.0   boot       6f24462b-e9da-4be1-ac8f-9297b4b737c1  184.6M    41% /boot
├─nvme0n1p4 xfs               root       51066397-2166-4516-a52a-8d1e1bfe2433   12.6G    14% /sysroot/ostree/deploy/fedora-coreos/var
│                                                                                            /sysroot
│                                                                                            /etc
└─nvme0n1p5 crypto_LUKS 2                39f443db-cee4-4b7d-b86c-3167cfd432ce
  └─var     xfs               var        8c7cd38f-8ecf-48db-827a-c176f6c95f2c  441.7G     2% /var
```

From these log lines, I believe the system accessed the TPM2 component and Clevis successfully retrieved the LUKS key:

```
stephane@stephane-coreos:~$ journalctl -o short-monotonic -b 0 -t systemd | grep -i "clevis\|tpm2\|cryptsetup\|luks"
[   23.402721] stephane-coreos systemd[1]: Created slice system-systemd\x2dcryptsetup.slice - Encrypted Volume Units Service Slice.
[   23.402756] stephane-coreos systemd[1]: Started clevis-luks-askpass.path - Forward Password Requests to Clevis Directory Watch.
[   23.402842] stephane-coreos systemd[1]: Reached target cryptsetup-pre.target - Local Encrypted Volumes (Pre).
[   23.855556] stephane-coreos systemd[1]: Reached target tpm2.target - Trusted Platform Module.
[   23.893369] stephane-coreos systemd[1]: Starting systemd-cryptsetup@var.service - Cryptography Setup for var...
[   23.925184] stephane-coreos systemd[1]: Finished systemd-cryptsetup@var.service - Cryptography Setup for var.
[   23.927713] stephane-coreos systemd[1]: Reached target cryptsetup.target - Local Encrypted Volumes.
[   25.376919] stephane-coreos systemd[1]: Reached target remote-cryptsetup.target - Remote Encrypted Volumes.
```

I then disabled the TPM feature in the server's BIOS and restarted the system. The console then prompted me
to enter the LUKS password I had configured in [`./coreos-custom-iso-config.bu`](coreos-custom-iso-config.bu).
Note that at this stage, the keyboard was already configured to `fr`.  
The `/var/` volume was successfully mounted and is accessible.

Teardown:

```sh
$ rm -rf disks/ images/
```
