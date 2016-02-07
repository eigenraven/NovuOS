module deficode;

import uefi;
import novuos.bootdata;

OSBootData BootData;
EFI_SYSTEM_TABLE *ST;
EFI_BOOT_SERVICES *BS;
wchar[3] NewLine = ['\r','\n','\0'];
wchar[64] StrBuffer;

extern(C) void* _Dmodule_ref;
extern(C) void* _tls_index = null;

@nogc:
nothrow:

void itoaBuffer(int v)
{
	int[10] POTS = [
	1, // 0
	10,
	100,
	1000,
	10000,
	100000,
	1000000,
	10000000,
	100000000,
	1000000000 // 9
	];
	wchar* ptr = StrBuffer.ptr;
	if(v==0)
	{
		*(ptr++) = '0';
	}
	else
	{
		if(v<0)
		{
			v=-v;
			*(ptr++) = '-';
		}
		bool f = false;
		for(int i=9; i>=0; i--)
		{
			if(f || v>=POTS[i])
			{
				f = true;
				int dg = (v/POTS[i]);
				*(ptr++) = cast(wchar)(dg+'0');
				v -= dg * POTS[i];
			}
		}
	}
	*(ptr++) = '\0';
}

void ShowBootNumber(int v)
{
	itoaBuffer(v);
	ST.ConOut.OutputString(ST.ConOut, StrBuffer.ptr);
}

void ShowBootString(const(wchar)[] lstr)
{
	ST.ConOut.OutputString(ST.ConOut, cast(CHAR16*)(lstr.ptr));
}

void ShowBootStringLn(const(wchar)[] lstr)
{
	ST.ConOut.OutputString(ST.ConOut, cast(CHAR16*)(lstr.ptr));
	ST.ConOut.OutputString(ST.ConOut, NewLine.ptr);
}

void CheckEfiCode(EFI_STATUS st, const(wchar)[] msg)
{
	int sti = cast(int)st;
	if(sti<0)
	{
		ShowBootString("[ERR:"w);
		ShowBootNumber(sti);
		ShowBootString("] ");
		ShowBootStringLn(msg);
		while(1){}
	}
	else if(sti>0)
	{
		ShowBootString("[WARN:"w);
		ShowBootNumber(sti);
		ShowBootString("] ");
		ShowBootStringLn(msg);
	}
}

void LoadProtocols()
{
	GUID GOP_GUID = EFI_GRAPHICS_OUTPUT_PROTOCOL_GUID;
	CheckEfiCode(BS.LocateProtocol(&GOP_GUID, null, cast(void**)(&BootData.GOP)),"Acquiring Graphics Output Protocl"w);
}

extern(C) EFI_STATUS defi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable)
{
	ST = SystemTable;
	BS = ST.BootServices;
	ShowBootStringLn("Hello D UEFI world!"w);
	BootData.ST = ST;
	BS.SetWatchdogTimer(0, 0, 0, null);
	LoadProtocols();
	ShowBootStringLn("NovuOS bootloader");
	while(1){}
}
