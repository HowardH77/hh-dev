/* Name:        %I%
 * Synopsis:    printargs -c -i -q commandline
 * Description: printargs displays cmdline arguments.  This is useful for debugging 
 *              shell scripts that escape the space, backslash, quote chars ('"`)
 *              and other wildcard characters (eg: "[*?]").
 *                Options: -c  Echo the command line
 *                         -i  Supress argument indices display
 *                         -q  Supress single quotes surrounding each argument display
 */

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

int
main(int argc, char *argv[])
{
	int opt;
	extern int optind;
	int echo_cmdline = 0; 
	int display_indices = 1; 
	int indx;
	char *quotes = "'";
	char *spaces = "";

	while ((opt = getopt(argc, argv, "ciq")) != EOF) {
		switch(opt) {
		case 'c': 
			echo_cmdline = 1;
			break;
		case 'i':
			display_indices = 0;
			break;
		case 'q':
			quotes = "";
			break;
		default:
			fprintf(stderr, "%s: Invalid option '%c'\n", argv[0], opt);
			fprintf(stderr, "Syntax: %s [-ciq] command command_options command_args ...", argv[0]);
			exit(1);
		}
	}

	--argc;
	if (echo_cmdline == 1) {
		printf("CmdLine: ");
		for (indx = optind; indx <= argc; ++indx)
			printf("%s%c", argv[indx], indx < argc ? ' ' : '\n');
	}


	for (indx = optind; indx <= argc; ++indx) {
		if (display_indices == 1)
			printf("%d : ", indx - optind + 1);
		printf("%s%s%s\n", quotes, argv[indx], quotes);
	}

	exit(0);
}
