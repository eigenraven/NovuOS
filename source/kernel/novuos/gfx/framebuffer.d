module novuos.gfx.framebuffer;

import novuos.bootdata;

nothrow:
@nogc:

enum FramebufferFormat : ubyte
{
	RGB,
	BGR
}

struct Framebuffer
{
	uint* pixels;
	size_t width, height, stride;
	FramebufferFormat format;
	
	void initFromBootdata(OSBootData* bd)
	{
		pixels = bd.FB.pixels;
	}
	
}
