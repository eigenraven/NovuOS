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
	uint* ipixels;
	size_t width, height, stride;
	FramebufferFormat format;

	nothrow:
	@nogc:

	void initFromBootdata(OSBootData* bd)
	{
		pixels = cast(ubyte*) bd.FB.pixels;
		ipixels = cast(uint*) pixels;
		width = bd.FB.w;
		height = bd.FB.h;
		stride = bd.FB.stride;
		switch (bd.FB.pformat)
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
		foreach (size_t i; 0 .. stride * height)
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
			color = R << 16 + G << 8 + B;
			break;
		case BGR32:
			color = B << 16 + G << 8 + R;
			break;
		default:
			break;
		}
		foreach (size_t i; 0 .. stride * height)
		{
			ipixels[i] = color;
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

	/// Draw monochromatic data bitmap (8 pixels per byte) with a specified color
	void drawBitmap(ubyte* src, size_t src_x, size_t src_y, size_t w, size_t h,
		size_t src_stride, size_t dst_x, size_t dst_y, ubyte R, ubyte G, ubyte B)
	{
		uint color;
		switch (format) with (FramebufferFormat)
		{
		case RGB32:
			color = R << 16 + G << 8 + B;
			break;
		case BGR32:
			color = B << 16 + G << 8 + R;
			break;
		default:
			break;
		}
		size_t limy = dst_y + h;
		if (limy > height)
		{
			limy = height;
		}
		size_t limx = dst_x + w;
		if (limx > width)
		{
			limx = width;
		}
		for (size_t dy = dst_y, sy = src_y; dy < limy; dy++, sy++)
		{
			for (size_t dx = dst_x, sx = src_x; dx < limx; dx++, sx++)
			{
				ubyte pix = src[src_stride * sy + (sx >> 3)] & (1 << (sx & 7));
				if (pix > 0)
				{
					ipixels[stride * dy + dx] = color;
				}
			}
		}
	}

}
