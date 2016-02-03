#include <efi.h>
#include <efilib.h>
 
EFI_STATUS efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable)
{
  EFI_STATUS Status;
  EFI_INPUT_KEY Key;
  EFI_MEMORY_DESCRIPTOR *Memmap;
  UINTN MemmapSize=0, MemmapDescriptorSize, MemmapKey, LastMemmapPages;
  UINT32 MemmapDescriptorVersion;
  ST = SystemTable;
  ST->BootServices->SetWatchdogTimer(0, 0, 0, NULL);

  Status = ST->ConOut->OutputString(ST->ConOut, L"NovuOS UEFI Loader\n\r");
  if (EFI_ERROR(Status))
    return Status;
  
  Status = ST->ConOut->OutputString(ST->ConOut, L"Getting memory map\n\r");
  if (EFI_ERROR(Status))
    return Status;
  ST->BootServices->GetMemoryMap(&MemmapSize,NULL,&MemmapKey,&MemmapDescriptorSize,&MemmapDescriptorVersion);
  do
  {
    if(LastMemmapPages>0)
    {
      ST->BootServices->FreePages((UINTN)Memmap, LastMemmapPages);
    }
    LastMemmapPages = (MemmapSize/4096)+1;
    MemmapSize = LastMemmapPages*4096;
    Status = ST->BootServices->AllocatePages(AllocateAnyPages, EfiLoaderData, LastMemmapPages, (UINTN*)(&Memmap));
    if(EFI_ERROR(Status))
    {
      ST->ConOut->OutputString(ST->ConOut, L"[ERR] Could not allocate memory for memory map!\n\r");
      return Status;
    }
    Status = ST->BootServices->GetMemoryMap(&MemmapSize,Memmap,&MemmapKey,&MemmapDescriptorSize,&MemmapDescriptorVersion);
  }while(Status==EFI_BUFFER_TOO_SMALL);
  if(EFI_ERROR(Status))
  {
    ST->ConOut->OutputString(ST->ConOut, L"[ERR] Could not obtain memory map!\n\r");
    return Status;
  }
  Status = ST->ConOut->OutputString(ST->ConOut, L"Memory map obtained\n\r");
  if (EFI_ERROR(Status))
    return Status;
  
  Status = ST->ConIn->Reset(ST->ConIn, FALSE);
  if (EFI_ERROR(Status))
    return Status;

  while ((Status = ST->ConIn->ReadKeyStroke(ST->ConIn, &Key)) == EFI_NOT_READY) ;
  
  ST->BootServices->ExitBootServices(ImageHandle, MemmapKey);
  
  return Status;
}
