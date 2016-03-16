import reggae;

static this()
{
	defaultOptions.dCompiler = "ldc2";
	defaultOptions.isDubProject = false;
}

enum DFLAGS_FREESTANDING_ALLOWGC = `-d-version=NovuOS -conf=ldc2.conf -g -mtriple=x86_64-unknown-linux-elf -disable-red-zone -Iuefi-d/source -Isource/uefiloader/dsrc -defaultlib= -debuglib= -code-model=large -mattr=+sse,+sse2,-sse3 `;
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

enum string kernel_libc_path = "$project/output/libkc.a";

Target kernel_libc()
{
	import std.stdio, std.path, std.file;

	enum string CC = "clang -c -fno-builtin -nostdlib -nostdinc --target=x86_64-unknown-linux-elf -std=c11 -mcmodel=large -ffreestanding -O2 -mno-sse -mno-mmx" ~ " -Wno-implicit-function-declaration -Wno-invalid-noreturn -isystem source/kernellibc/includes -Isource/kernellibc/internals -Isource/kernellibc/platform/novuos/includes" ~ " -Isource/kernellibc/platform/novuos/internals -Isource/kernellibc/opt/nothread -I/home/kubasz/NovuOS/source/kernellibc/opt/c_locale ";
	enum sourcePaths = [
			"source/kernellibc/functions", "source/kernellibc/platform/novuos/functions",
			"source/kernellibc/opt/nothread", "/home/kubasz/NovuOS/source/kernellibc/opt/c_locale"
		];
	Target[] ksources = [];
	foreach (string srcPath; sourcePaths)
	{
		foreach (DirEntry de; dirEntries(srcPath, SpanMode.depth, true))
		{
			if (de.isFile() && extension(de.name) == ".c")
			{
				string outf = stripExtension(relativePath(de.name,
						buildNormalizedPath(getcwd(), "source/"))) ~ ".o";
				ksources ~= Target(`$project/output/` ~ outf, CC ~ " -o $out $in", Target(de.name));
			}
		}
	}
	return Target(kernel_libc_path, "ar rcs $out $in", ksources);
}

Target kernel_elf()
{
	import std.stdio, std.path, std.file;

	enum sourcePaths = ["source/kernel", "resources/"];
	Target[] ksources = [];
	foreach (string srcPath; sourcePaths)
	{
		foreach (DirEntry de; dirEntries(srcPath, SpanMode.depth, true))
		{
			if (de.isFile() && extension(de.name) == ".d")
			{
				if (baseName(de.name) == "object.d")
					continue;
				string outf = stripExtension(relativePath(de.name, getcwd())) ~ ".o";
				ksources ~= objectFile(SourceFile(de.name),
						Flags(DFLAGS_FREESTANDING), KERNEL_IMPORTS, KERNEL_SIMPORTS);
			}
		}
	}
	ksources ~= objectFile(SourceFile(`source/kernel/object.d`),
			Flags(DFLAGS_FREESTANDING_ALLOWGC), KERNEL_IMPORTS, KERNEL_SIMPORTS);
	ksources ~= Target(`$project/output/asmhelper.o`,
			`yasm -o $out -f elf64 -g dwarf2 $in`, Target(`source/kernel/asmhelper.s`));
	return Target(`$project/output/novuos.elf`,
			`ld -T source/kernel/linker.ld -nostdlib -nodefaultlibs -o $out $in`,
			ksources ~ Target(kernel_libc_path));
}

enum novuos_image = Target(`$project/output/bootimage.img`,
			`$project/rebuildImage.sh $out $in`, [uefi_app, Target(`$project/output/novuos.elf`)]);

mixin build!(uefi_app, kernel_libc, kernel_elf, novuos_image);
