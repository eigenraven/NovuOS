set arch i386:x86-64:intel
print "target remote localhost:1234"
print "add-symbol-file output/BOOTX64.EFI 0xB+TXT -s .data 0xB+DTA"
python exec(open("gdb_dbg.py").read())
display/5i $pc
target remote localhost:1234
