gdb.execute("file output/BOOTX64.EFI")
ssect = gdb.execute("info files", False, True)
gdb.execute("file")
lsect = ssect.splitlines()
print("Epoint [hex]:")
base = int(input(),16)
args = "add-symbol-file output/BOOTX64.EFI"
for line in lsect:
    ln = line.strip().split(' ')
    if(ln[0].startswith("Entry")):
        rbase = int(ln[2],16)
        base = base - rbase
        print("Found epoint: %x [diff: %x]"%(rbase, base))
    if(ln[0].startswith("0x")):
        sn = ln[4]
        sa = int(ln[0],16) + base
        if(sn==".text"):
            args = "%s 0x%x"%(args, sa)
        else:
            args = "%s -s %s 0x%x"%(args, sn, sa)
    pass
pass
gdb.execute(args)