#!/bin/sh
qemu-system-x86_64 -cpu qemu64 -name NovuOS -smp cpus=1,cores=2 -bios /usr/share/ovmf/ovmf_x64.bin -usb -usbdevice disk:format=raw:output/bootimage.img