module novuos.fbcon;

import confont_imp;
import novuos.gfx.framebuffer;

__gshared FramebufferConsole* fbcon;

extern(C) void kprintDString(const(dchar)* str, ulong len) nothrow @nogc
{
	if(fbcon!=null)
	{
		fbcon.printString(str[0..len]);
	}
}

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
		.fbcon = &this;
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
		return putCharAbs(dch, x * CharWidth + PadPixels, y * CharHeight + PadPixels, color);
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
			fb.fillRect(0, PadPixels + CharHeight * y, 0, fb.width, colBG);
			return true;
		case ClearScreen:
			x = 0;
			y = 0;
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
	void printString(const(dchar[]) str)
	{
		foreach (dchar ch; str)
		{
			if (ch == '\0')
				break;
			printChar(ch);
		}
	}

	/// Print a C string
	void printCString(const(char[]) str, int lim)
	{
		for (int i = 0; (i < lim); i++)
		{
			dchar ch = cast(dchar)(str[i]);
			if (ch == '\0')
			{
				return;
			}
			printChar(ch);
		}
	}

	enum BoxDraw : dchar
	{
		V = 0x2551,
		H = 0x2550,
		TL = 0x2554,
		TR = 0x2557,
		BL = 0x255A,
		BR = 0x255D,
		Box = 0x2588
	}

	/// Move cursor to a specified position
	void moveTo(ulong x, ulong y)
	{
		this.x = x;
		this.y = y;
	}

	/// Draw a box out of UTF box-draw characters, put cursor in the top-left corner of the inside
	void drawBox(ulong x, ulong y, ulong w, ulong h)
	{
		this.x = x + 1;
		this.y = y + 1;
		if (w <= 1)
		{
			if (h <= 1)
			{
				putChar(BoxDraw.Box, x, y, colFG);
			}
			else
			{
				foreach (ulong cy; y .. y + h)
				{
					putChar(BoxDraw.V, x, cy, colFG);
				}
			}
		}
		else
		{
			if (h <= 1)
			{
				foreach (ulong cx; x .. x + w)
				{
					putChar(BoxDraw.H, cx, y, colFG);
				}
			}
			else
			{
				w--;
				h--;
				// corners
				putChar(BoxDraw.TL, x, y, colFG);
				putChar(BoxDraw.TR, x + w, y, colFG);
				putChar(BoxDraw.BL, x, y + h, colFG);
				putChar(BoxDraw.BR, x + w, y + h, colFG);
				// top rule
				foreach (ulong cx; x + 1 .. x + w)
				{
					putChar(BoxDraw.H, cx, y, colFG);
				}
				// bottom rule
				foreach (ulong cx; x + 1 .. x + w)
				{
					putChar(BoxDraw.H, cx, y + h, colFG);
				}
				// left rule
				foreach (ulong cy; y + 1 .. y + h)
				{
					putChar(BoxDraw.V, x, cy, colFG);
				}
				// right rule
				foreach (ulong cy; y + 1 .. y + h)
				{
					putChar(BoxDraw.V, x + w, cy, colFG);
				}
			}
		}
	}

}
