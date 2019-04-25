main()
{
	int x = 1;
	int a = 10;

	if (a < 20) {
		print(x); // 1
	}

	x = x + 1;
	print(x);	// 2

	if (a > 20) {
		print(x);
	}

	x = x + 1;
	print(x);	// 3

	if (a < 20) {
		x = x + 1;
	} else {
		x = x - 1;
	}

	print(x);	// 4

	if (a > 20) {
		x = x - 1;
	} else {
		x = x + 1;
	}

	print(x);	// 5
	
	// result should be: "12345"
}
