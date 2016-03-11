module novuos.fbcon;

import confont_imp;
import novuos.gfx.framebuffer;

struct FramebufferConsole
{
	Framebuffer* fb;
nothrow:
@nogc:
	this(Framebuffer* f)
	{
		fb = f;
	}
	
	/// Draw a character on the specified x,y framebuffer coordinates
	void putCharAbs(dchar ch, uint x, uint y, ubyte R, ubyte G, ubyte B)
	{
		if(ch>65536)
			ch = 0;
		uint sz = confont_chars[ch*2];
		fb.drawBitmap(confont_bitmap.ptr, confont_chars[ch*2+1], 0, sz*8, 16, sz, x, y, R, G, B);
	}
	
}
