/* Name:         $Id: hd.c,v 1.2 20030502 23:56:11 howard Exp $
 * Synopsis:     hd [-c] file ...
 * Description:  Dump files in hex/ascii format.
 *               Options: -c Display character count
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <ctype.h>

#define SEP ' '
#define SEP2 ' '
#define SEP3 "  "


static void
display_chars(int *buf, int len)
{
	int indx = 0;

	for (indx = 0; indx < len; ++indx) {
		if (isprint(buf[indx]))
			putchar(buf[indx]);
		else
			putchar('.');
	}
}


static int
nibble2hex(int nibble)
{
	switch(nibble) {
	  case 0: return '0';
	  case 1: return '1';
	  case 2: return '2';
	  case 3: return '3';
	  case 4: return '4';
	  case 5: return '5';
	  case 6: return '6';
	  case 7: return '7';
	  case 8: return '8';
	  case 9: return '9';
	  case 10: return 'A';
	  case 11: return 'B';
	  case 12: return 'C';
	  case 13: return 'D';
	  case 14: return 'E';
	  case 15: return 'F';
	}
	
}


static void
display_hex(int ch)
{
	putchar(nibble2hex((ch >> 4) & 0xF));
	putchar(nibble2hex(ch & 0xF));
	putchar(SEP);
}


static int
hexdump(FILE *fp, int count_chars)
{
	int indx = 0;
	int buf[16];
	unsigned int count = 0;

	memset(buf, 0, sizeof(buf));
	while ((buf[indx] = fgetc(fp)) != EOF) {
		if (count_chars && indx == 0)
			printf("%.6x  ", count);
		else if (indx == 8)
			putchar(SEP2);
		display_hex(buf[indx++]);
		if (indx == 16) {
			fputs(SEP3, stdout);
			display_chars(buf, indx);
			putchar('\n');
			indx = 0;
		}
		++count;
	}
	if (indx > 0) {
		int indx2;
		for (indx2 = indx; indx2 < 16; ++indx2) {
			if (indx2 == 8) { putchar(SEP2); }
			putchar(' '); putchar(' '); putchar(SEP);
		}
		fputs(SEP3, stdout);
		display_chars(buf, indx);
		putchar('\n');
	}
	return 0;
}


int
main(int argc, char *argv[])
{
	char opt;
	extern int optind;
	int indx;
	FILE *fp;
	int count_chars = 0;

	while ((opt = getopt(argc, argv, "c")) != EOF) {
		switch(opt) {
		case 'c': count_chars = 1;
		          break;
		}
	}

	if (optind == argc) {
		hexdump(stdin, count_chars);
	} else {
		for (indx = optind; indx < argc; ++indx) {
			if (fp = fopen(argv[indx], "rb")) {
				hexdump(fp, count_chars);
				fclose(fp);
			}
		}
	}
	exit(0);
}
/*
:!cc % -o hd
:!gcc -g % -o hd
*/
