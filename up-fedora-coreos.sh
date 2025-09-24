#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/"

if [ ! -f "images/fedora-coreos-42.20250901.3.0-qemu.x86_64.qcow2" ]; then
    coreos-installer download \
        -s stable \
        -p qemu \
        -f qcow2.xz \
        --decompress \
        -C ./images/
fi

rm -f ./disks/coreos-1-disk.qcow2
qemu-img create \
    -f qcow2 \
    -F qcow2 -b \
    $(pwd)/images/fedora-coreos-42.20250901.3.0-qemu.x86_64.qcow2 \
    ./disks/coreos-1-disk.qcow2 \
    10G

butane config.bu > config.ign

IGNITION_CONFIG="$(pwd)/config.ign"

# virt-install \
#     --connect="qemu:///system" \
#     --name="coreos-1" \
#     --vcpus="2" \
#     --memory="2048" \
#     --os-variant="fedora-coreos-stable" \
#     --import \
#     --graphics=none \
#     --disk="size=10,backing_store=$(pwd)/images/fedora-coreos-42.20250901.3.0-qemu.x86_64.qcow2" \
#     --network bridge=virbr0 \
#     --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=${IGNITION_CONFIG}" \
#     --noautoconsole

# systemctl --user stop coreos-1
systemd-run --user --unit=coreos-1 \
    qemu-system-x86_64 \
        -name coreos-1 \
        -machine type=q35,accel=kvm \
        -cpu host \
        -smp 2 \
        -m 2048 \
        -nographic \
        -drive file=$(pwd)/disks/coreos-1-disk.qcow2,if=virtio,format=qcow2 \
        -netdev user,id=net0 \
        -device virtio-net-pci,netdev=net0 \
        -fw_cfg name=opt/com.coreos/config,file=${IGNITION_CONFIG} \
        -monitor unix:/tmp/coreos-1-monitor.sock,server,nowait \
        -serial unix:/tmp/coreos-1-console.sock,server,nowait
