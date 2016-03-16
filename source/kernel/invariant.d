
void _d_invariant(Object o) {}

extern (C)
{
	private alias MainFunc = int function(char[][] args);
	__gshared void* _PDCLIB_locale_tss;
	__gshared void* _PDCLIB_ascii_codec;
}

extern (C) int _d_run_main(int argc, char** argv, MainFunc mainFunc)
{
	return 0;
}
