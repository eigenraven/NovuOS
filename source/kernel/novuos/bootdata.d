module novuos.bootdata;

private alias UINT8 = ubyte;
private alias UINT16 = ushort;
private alias UINT32 = uint;
private alias UINT64 = ulong;

private alias INT8 = byte;
private alias INT16 = short;
private alias INT32 = int;
private alias INT64 = long;

extern(C) struct OSBootData
{
    UINT32 screenX;
	UINT32 screenY;
	UINT32 screenStride;
	UINT32 *screenPtr;
	UINT8 screenFormat;
}
