import reggae;

enum UEFI_CC = `x86_64-w64-mingw32-gcc -ffreestanding -Isource/uefiloader/gnuefiinc -Isource/uefiloader/gnuefiinc/x86_64 -Isource/uefiloader/gnuefiinc/protocol -c `;
enum UEFI_LD = `x86_64-w64-mingw32-gcc -nostdlib -Wl,-dll -shared -Wl,--subsystem,10 -e efi_main `;

const uefi_obj_data = Target(`$project/output/uefi_data.o`, UEFI_CC~`-o $out $in`, Target(`$project/source/uefiloader/gnuefilib/data.c`));
const uefi_obj_main = Target(`$project/output/uefi_main.o`, UEFI_CC~`-o $out $in`, Target(`$project/source/uefiloader/csrc/novuefimain.c`));
const uefi_app = Target(`$project/output/BOOTX64.EFI`, UEFI_LD~`-o $out $in -lgcc`, [uefi_obj_data,uefi_obj_main]);

const novuos_image = Target(`$project/output/bootimage.img`, `$project/rebuildImage.sh $out $in`, [uefi_app]);

mixin build!(novuos_image);
