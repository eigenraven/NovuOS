module novuos.fbcon;

import confont_0;
import novuos.gfx.framebuffer;

private __gshared ConfontChar[256] asciiCache;
private __gshared int unicodeIndex;
private __gshared bool asciiCached;

void initFbconCache() nothrow @nogc
{
	asciiCached = true;
	int idx = 1;
	for(int i=0;i<asciiCache.length;i++)
	{
		if(confont_0_chars[idx].id > i)
		{
			asciiCache[i] = confont_0_chars[0]; // to undefined char
		}
		else
		{
			asciiCache[i] = confont_0_chars[idx++];
		}
	}
	unicodeIndex = 0;
	while(confont_0_chars[unicodeIndex].id<256)unicodeIndex++;
}

struct FramebufferConsole
{
	Framebuffer* fb;
nothrow:
@nogc:
	this(Framebuffer* f)
	{
		fb = f;
	}
	
	/// Draw a character on the specified x,y framebuffer coordinates (position of baseline)
	void putCharAbs(dchar ch, uint x, uint y, ubyte R, ubyte G, ubyte B)
	{
		if(ch<256)
		{
			ConfontChar* c = &asciiCache[cast(ubyte)ch];
			fb.drawBitmap(confont_0_bits.ptr, c.x, c.y, c.width, c.height, confont_0_width/8, x+c.xoffset, y+c.yoffset, R, G, B);
		}
	}
	
}
