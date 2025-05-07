#!/bin/bash
set +ex

BOX_NAME=raspios-lite-cloudinit

vagrant box remove $BOX_NAME || true

qemu-img convert \
    -O qcow2 \
    ../deploy/2025-04-19-raspios-bookworm-armhf-lite-cloud-init.img \
    $BOX_NAME.qcow2

curl -sSL https://raw.githubusercontent.com/vagrant-libvirt/vagrant-libvirt/refs/tags/0.12.2/tools/create_box.sh \
    | bash -s - $BOX_NAME.qcow2

exit 0

rm $BOX_NAME.qcow2

vagrant box add $BOX_NAME.box --name $BOX_NAME

rm $BOX_NAME.box
