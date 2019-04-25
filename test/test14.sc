main()
{
	int i = 0;
	int x[10];

	for (; i < 10; i = i + 1) {
		x[i] = i;
		print(x[i]);
	}

	for (i = 9; i >= 0; i = i - 1) {
		print(x[i]);
	} 
	
	// result should be: "01234567899876543210"
}
