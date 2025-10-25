#!/usr/bin/env osh

cd "$(dirname "$0")"

cat << 'EOF'
If you want to reinstall the VM, you must delete `./disks/coreos-disk.qcow2` with:

$ rm ./disks/coreos-disk.qcow2

EOF

if [ ! -f "./disks/coreos-disk.qcow2" ]; then
    ... qemu-img create
        -f qcow2
        ./disks/coreos-disk.qcow2
        10G;
fi

# -boot parameter didn't work because this VM use UEFI
... qemu-system-x86_64
    -name coreos-custom-iso-1
    -machine type=q35,accel=kvm
    -cpu host
    -smp 2
    -m 4048
    -bios /usr/share/edk2/ovmf/OVMF_CODE.fd
    # disk
    -drive file=$(pwd)/disks/coreos-disk.qcow2,id=hd0,if=none,format=qcow2
    -device virtio-blk-pci,drive=hd0,bootindex=0
    # cdrom
    -drive if=none,id=cd0,media=cdrom,file=$(pwd)/images/fedora-coreos-custom-for-qemu.iso
    -device ide-cd,drive=cd0,bootindex=1;

