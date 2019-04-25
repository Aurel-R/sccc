main()
{
	int x[2][3];
	int i;
	int j;

	for (i = 0; i < 2; i = i + 1) {
		for (j = 0; j < 3; j = j + 1) {
			x[i][j] = i + j;
			print(x[i][j]);
		}
	}

	// result should be: "012123"	
}
