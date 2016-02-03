#!/bin/sh
#IMAGE_PATH=output/bootimage.img
IMAGE_PATH=$1

rm -f $IMAGE_PATH
rm -f /tmp/part.img

dd if=/dev/zero of=$IMAGE_PATH bs=512 count=262144
parted $IMAGE_PATH -s -a minimal mklabel gpt
parted $IMAGE_PATH -s -a minimal mkpart EFI FAT32 2048s 131071s
parted $IMAGE_PATH -s -a minimal name 1 UEFI
parted $IMAGE_PATH -s -a minimal toggle 1 boot
parted $IMAGE_PATH -s -a minimal mkpart NOVUOS FAT32 131072s 100%
parted $IMAGE_PATH -s -a minimal name 2 NOVUOS
parted $IMAGE_PATH -s -a minimal print

dd if=/dev/zero of=/tmp/part.img bs=512 count=129024
mkfs.vfat /tmp/part.img -F 32

mmd -i /tmp/part.img ::/EFI
mmd -i /tmp/part.img ::/EFI/BOOT
mcopy -i /tmp/part.img $2 ::/EFI/BOOT

dd if=/tmp/part.img of=$IMAGE_PATH bs=512 count=129024 seek=2048 conv=notrunc
