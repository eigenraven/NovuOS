
void _d_invariant(Object o) {}

extern (C)
{
	private alias MainFunc = int function(char[][] args);
}

extern (C) int _d_run_main(int argc, char** argv, MainFunc mainFunc)
{
	return 0;
}
