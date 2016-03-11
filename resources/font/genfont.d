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

enum string Head = "module confont;";

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
	foreach (string line; fp.byLine)
	{
		if (line.length < 6)
			continue;
		string xchr = line[0 .. 4];
		string xbmp = line[5 .. $];
		uint chr = parse(xchr.dup, 16);
		Chardef* S = &chars[chr];
		S.dataidx = dataptr;
		if (xbmp.length >= 64)
		{
			S.size = 2;
			
		}
	}
	fp.close();
	ofp.close();
}
