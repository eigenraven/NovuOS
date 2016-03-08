module novuos.gfx.framebuffer;

import novuos.bootdata;

nothrow:
@nogc:

enum FramebufferFormat : ubyte
{
	RGB32,
	BGR32
}

struct Framebuffer
{
	ubyte* pixels;
	size_t width, height, stride;
	FramebufferFormat format;

	void initFromBootdata(OSBootData* bd)
	{
		pixels = cast(ubyte*) bd.FB.pixels;
		width = bd.FB.w;
		height = bd.FB.h;
		stride = bd.FB.stride;
		switch (bd.FB.format)
		{
		case BootFramebufferFormat.RGB:
			format = FramebufferFormat.RGB32;
			break;
		case BootFramebufferFormat.BGR:
			format = FramebufferFormat.BGR32;
			break;
		default:
			format = FramebufferFormat.RGB32;
			break;
		}
	}

	void clear()
	{
		uint* px = cast(uint*) pixels;
		foreach (size_t i; 0 .. stride * h)
		{
			px[i] = 0;
		}
	}
	
	void clearToColor(ubyte R, ubyte G, ubyte B)
	{
		uint color;
		switch (format) with (FramebufferFormat)
		{
		case RGB32:
			color = R<<16 + G<<8 + B;
			break;
		case BGR32:
			color = B<<16 + G<<8 + R;
			break;
		default:
			break;
		}
		uint* px = cast(uint*) pixels;
		foreach (size_t i; 0 .. stride * h)
		{
			px[i] = color;
		}
	}

	void putPixel(size_t x, size_t y, ubyte R, ubyte G, ubyte B)
	{
		size_t idx = (stride * y + x) * 4;
		switch (format) with (FramebufferFormat)
		{
		case RGB32:
			pixels[idx] = R;
			pixels[idx + 1] = G;
			pixels[idx + 2] = B;
			break;
		case BGR32:
			pixels[idx] = B;
			pixels[idx + 1] = G;
			pixels[idx + 2] = R;
			break;
		default:
			break;
		}
	}

}
