# Install Fedora CoreOS ISO custom image on QEMU

In this playground, I use [Oils](https://oils.pub/). To install this shell, follow instructions: <https://github.com/oils-for-unix/oils/wiki/Oils-Deployments>.

Prerequisites:

```
$ sudo dnf install \
    butane \
    coreos-installer \
    qemu-kvm \
    swtpm \
    swtpm-tools \
    edk2-ovmf
```

Download the stable x86_64 metal ISO, generate the Ignition configuration, and build the custom ISO:


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
$ rm -rf disks/ images/
```
