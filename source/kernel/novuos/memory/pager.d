/// Page-management code
module novuos.memory.pager;

import novuos.basictypes;

struct PagePML4E
{
    ulong field; /// Raw field
    
    alias P = BitField!(ulong, field, 1, 0); /// Present
    alias RW = BitField!(ulong, field, 1, 1); /// Read/Write=1, Read-Only=0
    alias US = BitField!(ulong, field, 1, 2); /// User=1, Supervisor=0
    alias PWT = BitField!(ulong, field, 1, 3); /// Writethrough
    alias PCD  =BitField!(ulong, field, 1, 4); /// Page-level cache disable
    alias A  =BitField!(ulong, field, 1, 5); /// Accessed
    alias MBZ  =BitField!(ulong, field, 2, 7); /// Must be zero
    alias AVL  =BitField!(ulong, field, 3, 9); /// To software
    alias Addr  =BitField!(ulong, field, 40, 12); /// Address
    alias NX  =BitField!(ulong, field, 1, 63); /// No-execute
}
static assert(PagePML4E.sizeof == 8);
alias PageTable = PagePML4E[512];

struct PagePDPE
{
    ulong field; /// Raw field
    
    alias P = BitField!(ulong, field, 1, 0); /// Present
    alias RW = BitField!(ulong, field, 1, 1); /// Read/Write=1, Read-Only=0
    alias US = BitField!(ulong, field, 1, 2); /// User=1, Supervisor=0
    alias PWT = BitField!(ulong, field, 1, 3); /// Writethrough
    alias PCD  =BitField!(ulong, field, 1, 4); /// Page-level cache disable
    alias A  =BitField!(ulong, field, 1, 5); /// Accessed
    alias MBZ  =BitField!(ulong, field, 2, 7); /// Must be zero
    alias AVL  =BitField!(ulong, field, 3, 9); /// To software
    alias Addr  =BitField!(ulong, field, 40, 12); /// Address
    alias NX  =BitField!(ulong, field, 1, 63); /// No-execute
}
static assert(PagePDPE.sizeof == 8);

struct PagePDE
{
    ulong field; /// Raw field
    
    alias P = BitField!(ulong, field, 1, 0); /// Present
    alias RW = BitField!(ulong, field, 1, 1); /// Read/Write=1, Read-Only=0
    alias US = BitField!(ulong, field, 1, 2); /// User=1, Supervisor=0
    alias PWT = BitField!(ulong, field, 1, 3); /// Writethrough
    alias PCD  =BitField!(ulong, field, 1, 4); /// Page-level cache disable
    alias A  =BitField!(ulong, field, 1, 5); /// Accessed
    alias AVL  =BitField!(ulong, field, 3, 9); /// To software
    alias Addr  =BitField!(ulong, field, 40, 12); /// Address
    alias NX  =BitField!(ulong, field, 1, 63); /// No-execute
}
static assert(PagePDE.sizeof == 8);

struct PagePTE
{
    ulong field; /// Raw field
    
    alias P = BitField!(ulong, field, 1, 0); /// Present
    alias RW = BitField!(ulong, field, 1, 1); /// Read/Write=1, Read-Only=0
    alias US = BitField!(ulong, field, 1, 2); /// User=1, Supervisor=0
    alias PWT = BitField!(ulong, field, 1, 3); /// Writethrough
    alias PCD  =BitField!(ulong, field, 1, 4); /// Page-level cache disable
    alias A  =BitField!(ulong, field, 1, 5); /// Accessed
    alias D  =BitField!(ulong, field, 1, 6); /// Dirty
    alias PAT=BitField!(ulong, field, 1, 7); /// Page attribute table
    alias G  =BitField!(ulong, field, 1, 8); /// Global page
    alias AVL=BitField!(ulong, field, 3, 9); /// To software
    alias Addr  =BitField!(ulong, field, 40, 12); /// Address
    alias NX  =BitField!(ulong, field, 1, 63); /// No-execute
}
static assert(PagePTE.sizeof == 8);
