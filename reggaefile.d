import reggae;

static this()
{
    defaultOptions.dCompiler = "ldc2";
}

enum DFLAGS_FREESTANDING = `-mtriple=x86_64-unknown-linux-elf -disable-red-zone -Iuefi-d/source -Isource/uefiloader/dsrc -nogc -defaultlib= -debuglib= -code-model=large -mattr=+sse,+sse2,-sse3`;

enum UEFI_DC = `ldc2 -mtriple=x86_64-unknown-windows-coff -disable-red-zone -boundscheck=off -nogc -mattr=-sse,-sse2,-sse3 -defaultlib= -debuglib= -code-model=large -Iuefi-d/source -Isource/kernel -Isource/uefiloader/dsrc -Iuefi-d/source -c `;
enum UEFI_LD = `x86_64-w64-mingw32-gcc -Wl,--gc-sections -nostdlib -Wl,-dll -shared -Wl,--subsystem,10 -e efi_main `;

const uefi_obj_btypes = Target(`$project/output/uefi_btypes.obj`,
    UEFI_DC ~ `-of=$out $in`, Target(`$project/source/kernel/novuos/basictypes.d`));
const uefi_obj_pager = Target(`$project/output/uefi_pager.obj`,
    UEFI_DC ~ `-of=$out $in`, Target(`$project/source/kernel/novuos/memory/pager.d`));
const uefi_obj_dmain = Target(`$project/output/uefi_dmain.obj`,
    UEFI_DC ~ `-of=$out $in`, Target(`$project/source/uefiloader/dsrc/deficode.d`));
const uefi_app = Target(`$project/output/BOOTX64.EFI`,
    UEFI_LD ~ `-o $out $in -lgcc`, [uefi_obj_dmain, uefi_obj_pager, uefi_obj_btypes]);

const kernel_obj_main = objectFile(SourceFile(`source/kernel/novuos/kmain.d`),
    Flags(DFLAGS_FREESTANDING), ImportPaths([`source/kernel`]));

const kernel_elf = Target(`$project/output/novuos.elf`,
    `ld -T $project/source/kernel/linker.ld -nostdlib -nodefaultlibs -o $out $in`,
    [kernel_obj_main]);

const novuos_image = Target(`$project/output/bootimage.img`,
    `$project/rebuildImage.sh $out $in`, [uefi_app, kernel_elf]);

mixin build!(kernel_elf, novuos_image);
