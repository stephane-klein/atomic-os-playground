# Launch Fedora CoreOS in QEMU with LUKS and TPM2 emulation and NBDE Tang server

This emulation environment is a bit more complicated than the first one because a TPM2 emulation is configured.

The TPM2 emulation is performed by [swtpm](https://github.com/stefanberger/swtpm/wiki).

This environment uses the UEFI implementation: [edk2-ovmf](https://github.com/tianocore/tianocore.github.io/wiki/OVMF).

This playground uses a [Tang](https://github.com/latchset/tang) server for *[Network-Bound Disk Encryption](https://notes.sklein.xyz/Network-Bound%20Disk%20Encryption/)*,
launched via Docker (Tang Docker Image source code: <https://github.com/padhi-homelab/docker_tang>).

The configuration uses a 2-threshold policy, meaning Clevis requires both TPM2 pin and Tang pin to unlock the encrypted LUKS `/var/` partition.
If either is unavailable, Clevis prompts the user for the passphrase.


**Prerequisites**

In this playground, I use [Oils](https://oils.pub/). To install this shell, follow instructions: <https://github.com/oils-for-unix/oils/wiki/Oils-Deployments>.

Next:

```
$ sudo dnf install \
    butane \
    coreos-installer \
    qemu-kvm \
    swtpm \
    swtpm-tools \
    edk2-ovmf \
    docker-cli \
    docker-compose
```

**Getting started**

Download the stable `x86_64` metal ISO, generate the Ignition configuration, and build the custom ISO:


```sh
$ ./create-custom-iso.sh
```

Launch the QEMU VM with the custom ISO:

```sh
$ ./up-qemu-vm.sh
```

Note: On first boot, the script installs CoreOS to the virtual disk. Next boot CoreOS ignition configuration is exectued.

You can also connect to VM with *ssh*:

```sh
$ ssh-keygen -R "[127.0.0.1]:2222"
$ ssh -p 2222 -o StrictHostKeyChecking=no stephane@127.0.0.1
```

Teardown:

```sh
$ systemctl --user stop "swtpm-qemu-coreos"
$ rm -rf disks/ images/
```

## How to switch from 2 required ping to 1 or the opposite?

If you want to change the threshold value, you can follow this method:

```sh
$ ssh -p 2222 -o StrictHostKeyChecking=no stephane@127.0.0.1
root@stephane-coreos:/var/home/stephane# clevis luks list -d /dev/vda5
1: sss '{"t":2,"pins":{"tang":[{"url":"http://10.0.2.2:1234"}],"tpm2":[{"hash":"sha256","key":"ecc"}]}}'
root@stephane-coreos:/var/home/stephane# clevis luks unbind -d /dev/vda5 -s 1 -f
root@stephane-coreos:/var/home/stephane# clevis luks list -d /dev/vda5
root@stephane-coreos:/var/home/stephane#
root@stephane-coreos:/var/home/stephane# clevis luks bind -d "/dev/vda5" sss '{"t":1,"pins":{"tpm2":{"hash":"sha256","key":"ecc"}, "tang":[{"url":"http://10.0.2.2:1234"}]}}'
Enter existing LUKS password:
The advertisement contains the following signing keys:

dx9dNzgs-DeXg0SCBQW5rb7WQkSIN1B8MIgcO6WxJfI

Do you wish to trust these keys? [ynYN] y
root@stephane-coreos:/var/home/stephane# clevis luks list -d /dev/vda5
1: sss '{"t":1,"pins":{"tang":[{"url":"http://10.0.2.2:1234"}],"tpm2":[{"hash":"sha256","key":"ecc"}]}}'
```
