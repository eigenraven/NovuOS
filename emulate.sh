#!/bin/sh
qemu-system-x86_64 -enable-kvm -serial pty -monitor stdio -display sdl -vga std -cpu kvm64,+ssse3 -M q35 -name NovuOS -bios /usr/share/ovmf/ovmf_x64.bin -drive file=output/bootimage.img,format=raw,if=virtio,cache=none -no-reboot -no-shutdown -m 1G -s $*
