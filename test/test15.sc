main()
{
	int x[3];
	int y[3];
	int i;

	for (i = 0; i < 3; i = i + 1) {
		x[i] = i;
		y[i] = x[i];
		print(y[i]);
	}
	
	// result should be: "012"
}
