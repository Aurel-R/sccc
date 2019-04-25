main()
{
	int x = 0;
	int y = 10;

	while (x < 10 && y != 5) {
		x = x + 1;
		y = y - 1;
	}

	print(x);	// 5
	print(y);	// 5

	// result should be: "55"
}
