# Launch Fedora CoreOS in QEMU with LUKS and TPM2 emulation

This emulation environment is a bit more complicated than the first one because a TPM2 emulation is configured.

The TPM2 emulation is performed by [swtpm](https://github.com/stefanberger/swtpm/wiki).

This environment uses the UEFI implementation: [edk2-ovmf](https://github.com/tianocore/tianocore.github.io/wiki/OVMF).

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
    edk2-ovmf
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

Note: On first boot, the script installs CoreOS to the virtual disk. Subsequent boots use the installed system.

Teardown:

```sh
$ systemctl --user stop "swtpm-qemu-coreos"
$ rm -rf disks/ images/
```
