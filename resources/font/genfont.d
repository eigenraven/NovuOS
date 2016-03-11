#!/usr/bin/env rdmd

import std.stdio;
import std.string;
import std.format;
import std.conv;
import std.algorithm;
import std.range;
import std.array;

struct Chardef
{
	ushort size; // 0 - no data, 1 - 8x16, 2 - 16x16
	uint dataidx;
}

Chardef[65536] chars;
ubyte[] data;

enum string Head = "module confont;\n\n";

void main(string[] args)
{
	if (args.length != 2)
	{
		writeln("Usage: " ~ args[0] ~ " unifont.txt");
		return;
	}
	File ofp = File("confont.d", "w");
	ofp.write(Head);
	File fp = File(args[1], "r");
	uint dataptr = 0;
	foreach (char[] line; fp.byLine)
	{
		if (line.length < 6)
			continue;
		auto xchr = line[0 .. 4];
		auto xbmp = line[5 .. $];
		auto pchr = xchr.dup;
		uint chr = parse!int(pchr, 16);
		Chardef* S = &chars[chr];
		S.dataidx = dataptr;
		uint cnt = 0;
		while (xbmp.length > 1)
		{
			auto pbmp = xbmp[0..2].dup;
			data ~= cast(ubyte)(parse!int(pbmp,16));
			xbmp = xbmp[2..$];
			cnt++;
		}
		if(cnt==32)
		{
			S.size = 2;
		}
		else if(cnt==16)
		{
			S.size = 1;
		}
		else
		{
			writefln("Error in bitmap char count: %d [%X]",cnt,chr);
		}
		dataptr += cnt;
	}
	fp.close();
	ofp.writefln("immutable(ubyte[%d]) confont_bitmap = [", data.length);
	int counter = 0;
	foreach(ubyte b; data)
	{
		ofp.writef("%u, ", b);
		counter++;
		if(counter==20)
		{
			counter = 0;
			ofp.writeln();
		}
	}
	ofp.writeln("];\n");
	ofp.writeln("/// two uints per char - size (0/1/2 wide) and data index");
	enum FullCharCount = chars.length * 2;
	ofp.writefln("immutable(uint[%d]) confont_chars = [", FullCharCount);
	counter = 0;
	for(int i=0;i<chars.length;i++)
	{
		Chardef* S = &chars[i];
		ofp.writef("%d, %d, ", S.size, S.dataidx);
		counter++;
		if(counter==10)
		{
			counter = 0;
			ofp.writeln();
		}
	}
	ofp.writeln("];");
	ofp.close();
}
