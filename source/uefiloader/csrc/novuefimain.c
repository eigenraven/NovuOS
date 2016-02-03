#include <efi.h>
#include <efilib.h>
 
EFI_STATUS efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable)
{
  EFI_STATUS Status;
  EFI_INPUT_KEY Key;
  ST = SystemTable;
  ST->BootServices->SetWatchdogTimer(0, 0, 0, NULL);

  Status = ST->ConOut->OutputString(ST->ConOut, L"NovuOS UEFI Loader\n\r");
  if (EFI_ERROR(Status))
  return Status;

  Status = ST->ConIn->Reset(ST->ConIn, FALSE);
  if (EFI_ERROR(Status))
  return Status;

  while ((Status = ST->ConIn->ReadKeyStroke(ST->ConIn, &Key)) == EFI_NOT_READY) ;

  return Status;
}
