#!/bin/sh
qemu-system-x86_64 -serial pty -S -monitor stdio -enable-kvm -display sdl -vga std -cpu qemu64 -name NovuOS -bios /usr/share/ovmf/ovmf_x64.bin -usb -usbdevice disk:format=raw:output/bootimage.img -m 1G -s -debugcon file:debug.log -global isa-debugcon.iobase=0x402 $*
