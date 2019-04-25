main()
{
	int i;
	int j;

	for (i = 0; i < 2; i = i + 1) {
		for (j = 0; j < 5; j = j + 1) {
			print(i);
			print(j);
		}
	}

	// result should be: "00010203041011121314" 
}
