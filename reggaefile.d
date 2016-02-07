import reggae;

static this()
{
    defaultOptions.dCompiler = "ldc2";
}

enum DFLAGS_FREESTANDING = `-mtriple=x86_64-unknown-linux-elf -nogc -defaultlib= -debuglib= -code-model=large`;

enum UEFI_CC = `x86_64-w64-mingw32-gcc -ffreestanding -Isource/uefiloader/gnuefiinc -Isource/uefiloader/gnuefiinc/x86_64 -Isource/uefiloader/gnuefiinc/protocol -c `;
enum UEFI_DC = `ldc2 -mtriple=x86_64-unknown-windows-coff -nogc -defaultlib= -debuglib= -code-model=large -Isource/uefiloader/csrc -Iuefi-d/source -c `;
enum UEFI_LD = `x86_64-w64-mingw32-gcc -nostdlib -Wl,-dll -shared -Wl,--subsystem,10 -e efi_main `;

const uefi_obj_data = Target(`$project/output/uefi_data.o`, UEFI_CC~`-o $out $in`, Target(`$project/source/uefiloader/gnuefilib/data.c`));
const uefi_obj_main = Target(`$project/output/uefi_main.o`, UEFI_CC~`-o $out $in`, Target(`$project/source/uefiloader/csrc/novuefimain.c`));
const uefi_obj_dmain = Target(`$project/output/uefi_dmain.obj`, UEFI_DC~`-of=$out $in`, Target(`$project/source/uefiloader/csrc/deficode.d`));
const uefi_app = Target(`$project/output/BOOTX64.EFI`, UEFI_LD~`-o $out $in -lgcc`, [uefi_obj_data,uefi_obj_main,uefi_obj_dmain]);

const kernel_obj_main = objectFile(SourceFile(`source/kernel/novuos/kmain.d`),  Flags(DFLAGS_FREESTANDING), ImportPaths([`source/kernel`]));

const kernel_elf = Target(`$project/output/novuos.elf`, `ld -T $project/source/kernel/linker.ld -nostdlib -nodefaultlibs -o $out $in`, [kernel_obj_main]);

const novuos_image = Target(`$project/output/bootimage.img`, `$project/rebuildImage.sh $out $in`, [uefi_app]);

mixin build!(kernel_elf, novuos_image);
