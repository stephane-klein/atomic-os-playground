#!/usr/bin/env osh
set -e

cd "$(dirname "$0")/"

mkdir -p images/

if [ ! -f "images/fedora-coreos-live-iso.x86_64.iso" ]; then
    tmpdir=$(mktemp -d)

    ... coreos-installer download
        -s stable
        -a x86_64
        -p metal
        -f iso
        -d
        -C "$tmpdir";

    mv "$tmpdir"/* images/fedora-coreos-live-iso.x86_64.iso
    rmdir "$tmpdir"
else
    cat << 'EOF'
Use images/fedora-coreos-live-iso.x86_64.iso already download.
Execute `rm images/fedora-coreos-live-iso.x86_64.iso` if you want to download new version.
EOF
fi

butane coreos-custom-iso-config.bu > coreos-custom-iso-config.ign

rm -f images/fedora-coreos-custom-for-baremetal.iso

# I use coreos.inst.skip_reboot so that I can remove the USB key before restarting, in order to boot from the NVMe drive
... coreos-installer iso customize
    --dest-ignition coreos-custom-iso-config.ign
    --dest-device /dev/nvme0n1
    -o images/fedora-coreos-custom-for-baremetal.iso
    images/fedora-coreos-live-iso.x86_64.iso;

cat << 'EOF' 
CoreOS custom iso builded in: images/fedora-coreos-custom-for-baremetal.iso

Execute:

$ ./write-to-usb-interactive.sh

to write ISO image on USB key
EOF
