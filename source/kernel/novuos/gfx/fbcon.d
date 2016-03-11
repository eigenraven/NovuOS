module novuos.fbcon;

import confont_imp;
import novuos.gfx.framebuffer;

struct FramebufferConsole
{
	enum uint PadPixels = 2;
	enum uint CharWidth = 8;
	enum uint CharHeight = 16;
	Framebuffer* fb;
	ulong w, h; /// Grid size
	ulong x, y; /// Cursor position
	uint colFG;
	uint colBG;
nothrow:
@nogc:
	this(Framebuffer* f)
	{
		fb = f;
		w = (fb.width - 2 * PadPixels) / (CharWidth * 2);
		w <<= 1;
		h = (fb.height - 2 * PadPixels) / CharHeight;
		x = 0;
		y = 0;
		colFG = fb.rgbToColor(255, 255, 255);
		colBG = 0;
	}

	/// Draw a character on the specified x,y framebuffer coordinates
	/// Returns: character width in grid cells
	uint putCharAbs(dchar dch, ulong x, ulong y, uint color)
	{
		ulong ch = cast(ulong) dch;
		if (ch > 65536)
			ch = 0;
		uint sz = confont_chars[2 * ch];
		fb.drawBitmapR(confont_bitmap.ptr + confont_chars[2 * ch + 1], 0, 0,
			sz * 8, 16, sz, x, y, color);
		return sz;
	}

	/// Draw a character on the specified x,y grid coordinates
	/// Returns: character width in grid cells
	uint putChar(dchar dch, ulong x, ulong y, uint color)
	{
		return putCharAbs(dch, x * CharWidth + PadPixels, y * CharHeight + PadPixels,
			color);
	}

	/// Set current print color
	void setColor(ubyte R, ubyte G, ubyte B)
	{
		colFG = fb.rgbToColor(R, G, B);
	}
	/// ditto
	void setColor(uint RGB)
	{
		setColor((RGB >> 16) & 0xFF, (RGB >> 8) & 0xFF, (RGB) & 0xFF);
	}

	enum Command : dchar
	{
		Newline = '\n',
		AfterCursorMove = 0xE500,
		ClearLine = 0xE501,
		ClearScreen = 0xE502
	}

	/// Control codes
	bool handleControlCode(dchar dch)
	{
		switch (dch) with (Command)
		{
		case Newline:
			y++;
			x = 0;
			if (y >= h)
			{
				fb.scrollUp(CharHeight);
				y--;
			}
			return true;
		case AfterCursorMove:
			if (x >= w)
			{
				x = 0;
				y++;
			}
			if (y >= h)
			{
				fb.scrollUp(CharHeight);
				y--;
			}
			return true;
		case ClearLine:
			x = 0;
			fb.fillRect(0, PadPixels + CharHeight*y, 0, fb.width, colBG);
			return true;
		case ClearScreen:
			x=0;
			y=0;
			fb.clearToColor(colBG);
			return true;
		default:
			return false;
		}
	}

	/// Write a character and move the cursor
	void printChar(dchar dch)
	{
		if (!handleControlCode(dch))
		{
			x += putChar(dch, x, y, colFG);
			handleControlCode(Command.AfterCursorMove);
		}
	}

	/// Print a string
	void printString(dstring str)
	{
		foreach (dchar ch; str)
		{
			printChar(ch);
		}
	}

}
