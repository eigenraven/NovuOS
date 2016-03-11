import reggae;

static this()
{
	defaultOptions.dCompiler = "ldc2";
	defaultOptions.isDubProject = false;
}

enum DFLAGS_FREESTANDING_ALLOWGC = `-conf=ldc2.conf -g -mtriple=x86_64-unknown-linux-elf -disable-red-zone -Iuefi-d/source -Isource/uefiloader/dsrc -defaultlib= -debuglib= -code-model=large -mattr=+sse,+sse2,-sse3 `;
enum DFLAGS_FREESTANDING = DFLAGS_FREESTANDING_ALLOWGC ~ ` -vgc -nogc`;

enum UEFI_DC = `ldc2 -mtriple=x86_64-unknown-windows-coff -disable-red-zone -boundscheck=off -nogc -mattr=-sse,-sse2,-sse3 -defaultlib= -debuglib= -code-model=large -Iuefi-d/source -Isource/kernel -Isource/uefiloader/dsrc -Iuefi-d/source -c `;
enum UEFI_LD = `x86_64-w64-mingw32-gcc -Wl,--gc-sections -nostdlib -Wl,-dll -shared -Bsymbolic -Wl,--subsystem,10  -Wl,--file-alignment=0x1000 -Wl,--section-alignment=0x1000 -e efi_main `;

enum KERNEL_PATHS = [`source/kernel/`, `resources/font/`];
enum KERNEL_IMPORTS = ImportPaths(KERNEL_PATHS);
enum KERNEL_SIMPORTS = StringImportPaths(KERNEL_PATHS);

enum uefi_obj_btypes = Target(`$project/output/uefi_btypes.obj`,
		UEFI_DC ~ `-g -of=$out $in`, Target(`$project/source/kernel/novuos/basictypes.d`));
enum uefi_obj_pager = Target(`$project/output/uefi_pager.obj`,
		UEFI_DC ~ `-g -of=$out $in`, Target(`$project/source/kernel/novuos/memory/pager.d`));
enum uefi_obj_dmain = Target(`$project/output/uefi_dmain.obj`,
		UEFI_DC ~ `-g -of=$out $in`, Target(`$project/source/uefiloader/dsrc/deficode.d`));
enum uefi_app = Target(`$project/output/BOOTX64.EFI`,
		UEFI_LD ~ `-o $out $in -lgcc`, [uefi_obj_dmain, uefi_obj_pager, uefi_obj_btypes]);

auto kObj(string mod)
{
	return objectFile(SourceFile(`source/kernel/novuos/` ~ mod),
		Flags(DFLAGS_FREESTANDING), KERNEL_IMPORTS, KERNEL_SIMPORTS);
}

auto rObj(string mod)
{
	return objectFile(SourceFile(`resources/` ~ mod),
		Flags(DFLAGS_FREESTANDING), KERNEL_IMPORTS, KERNEL_SIMPORTS);
}

auto kObjs(string[] arr)
{
	Target[] ot;
	foreach (e; arr)
	{
		ot ~= kObj(e);
	}
	return ot;
}

enum kernel_objs = [objectFile(SourceFile(`source/kernel/object.d`),
		Flags(DFLAGS_FREESTANDING_ALLOWGC), KERNEL_IMPORTS, KERNEL_SIMPORTS)] ~ kObjs(
		[`../invariant.d`,`kmain.d`, `bootdata.d`, `basictypes.d`, `memory/pager.d`,
		`gfx/framebuffer.d`, `gfx/fbcon.d`, `formats/elf.d`, `cpu/descriptors.d`]) ~ [rObj(
		`font/confont.d`)];

enum kernel_elf = Target(`output/novuos.elf`,
		`ld -T source/kernel/linker.ld -nostdlib -nodefaultlibs -o $out $in`, kernel_objs);

enum novuos_image = Target(`$project/output/bootimage.img`,
		`$project/rebuildImage.sh $out $in`, [uefi_app, kernel_elf]);

mixin build!(uefi_app, kernel_elf, novuos_image);
