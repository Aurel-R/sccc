main()
{
	int res = 0;
	int x = 1;
	int y = 3;

	if (x == 1 && y == 3) {
		res = res + 1;
	} 

	print(res);	// 1

	if (!(x == 10)) {
		res = res + 1;
	}

	print(res);	// 2

	if (y == 0 && x == 1) {
		res = res - 1;
	} else {
		res = res + 1;
	}

	print(res);	// 3

	if (x == 0 || (y == 3 && x > 0)) {
		res = res + 1;
	}
	
	print(res);	// 4

	// result should be: "1234"	
}


