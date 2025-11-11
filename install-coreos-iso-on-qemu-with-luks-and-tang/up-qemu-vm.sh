#!/usr/bin/env osh

cd "$(dirname "$0")"

cat << 'EOF'
If you want to reinstall the VM, you must delete `./disks/coreos-disk.qcow2` with:

$ rm ./disks/coreos-disk.qcow2

EOF

mkdir -p disks/
if [ ! -f "./disks/coreos-disk-luks.qcow2" ]; then
    ... qemu-img create
        -f qcow2
        ./disks/coreos-disk-luks.qcow2
        20G;
fi

systemctl --user is-active --quiet "swtpm-qemu-coreos" && systemctl --user stop "swtpm-qemu-coreos"

mkdir -p ./vm-tpm

... systemd-run --user --unit=swtpm-qemu-coreos
    swtpm socket
       --tpmstate dir=$(pwd)/vm-tpm
       --ctrl type=unixio,path=/tmp/swtpm-sock
       --tpm2
       --log level=20;

# -boot parameter didn't work because this VM use UEFI
... qemu-system-x86_64
    -name coreos-custom-iso-1
    -machine type=q35,accel=kvm
    -cpu host
    -smp 2
    -m 4048
    -bios /usr/share/edk2/ovmf/OVMF_CODE.fd
    # disk
    -drive file=$(pwd)/disks/coreos-disk-luks.qcow2,id=hd0,if=none,format=qcow2
    -device virtio-blk-pci,drive=hd0,bootindex=0
    # cdrom
    -drive if=none,id=cd0,media=cdrom,file=$(pwd)/images/fedora-coreos-custom-for-qemu.iso
    -device ide-cd,drive=cd0,bootindex=1
    # TPM2
    -chardev socket,id=chrtpm,path=/tmp/swtpm-sock
    -tpmdev emulator,id=tpm0,chardev=chrtpm
    -device tpm-tis,tpmdev=tpm0
    # Open ssh tunnel on localhost:2222
    -netdev user,id=net0,hostfwd=tcp::2222-:22
    -device virtio-net-pci,netdev=net0
    # 
    -monitor unix:/tmp/coreos-1-monitor.sock,server,nowait
    -serial unix:/tmp/coreos-1-console.sock,server,nowait
    ;
