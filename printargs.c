/* Name: printargs.c */

#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
	int indx;
	if (argc > 1) {
		printf("argc = %d\n", argc);
		for (indx = 1; indx < argc; ++indx) {
			printf("argv[%d] = '%s'\n", indx, argv[indx]);
		}
	}
	exit(0);
}
