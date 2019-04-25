main()
{
	int x;

	for (x = 0; x < 10; x = x + 1) {
		print(x);
	}

	x = 0;
	print(x);

	// result should be: "01234567890"
}
