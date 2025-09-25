#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/"

systemctl --user stop coreos-1
rm disks/*.qcow2
