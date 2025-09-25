#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/"

if [ ! -f "images/fedora-coreos-42.20250901.3.0-live-iso.x86_64.iso" ]; then
    coreos-installer download \
        -s stable \
        -a x86_64 \
        -p metal \
        -f iso \
        -d \
        -C images/
fi

butane config.bu > config.ign

rm -f images/fedora-coreos-custom.iso

# I use coreos.inst.skip_reboot so that I can remove the USB key before restarting, in order to boot from the NVMe drive
coreos-installer iso customize \
    --dest-ignition config.ign \
    --dest-device /dev/nvme0n1 \
    --live-karg-append "coreos.inst.skip_reboot" \
    -o images/fedora-coreos-custom.iso \
    images/fedora-coreos-42.20250901.3.0-live-iso.x86_64.iso

