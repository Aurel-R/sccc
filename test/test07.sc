main()
{
	int x = 0;
	int a = 1;
	int b = 2;

	if (a > 0 && b > 10) {
		x = x - 1; 
	} else {
		if (a == 1 && b == 2) {
			x = x + 1;
		}
		print(x);	// 1
	}

	if (a > 0 && b > 0 && (x == 0 || x == 1)) {
		x = x + 1;
	}

	print(x);	//2

	if (!(a < 0 || b < 0)) {
		if (a == 1 && b != 2) {
			x = x - 1;
		} else {
			x = x + 1;
		}
	}
	
	print(x);	// 3

	// result should be: "123"
}
