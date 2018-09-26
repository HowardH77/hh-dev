/* Name:        %Id%
 * Synopsis:    lxargs [-r] [-L max-lines] command command_options
 * Description: lxargs constructs and executes a command line similiar to xargs.
 *              lxargs is (IMHO) a simpler xargs that is line oriented, in 
 *              contrast to standard xargs which delimits items read by spaces.
 *              Note: Filenames with funny characters (spaces, newlines, quotes, ...)
 *              are handled by executing the generated command by the execv() function.  
 *              No parsing for a NULL character is required as in GNU xargs.
 *                Options: -r  Do not run command if there is no input.  The default 
 *                             will run the command even if there is no input.
 *                         -L  Use at most max-lines input lines per command line.
 *              Example: ls -1 *.log | lxargs -r /bin/rm -f
 */

#include <stdlib.h>
#include <stdio.h>
#include <getopt.h>

typedef struct llist_s {
	struct llist_s *next;
	char data[1];
} llist_t;


int 
do_command(char *argv[], int argc, llist_t *input_args, int n_input_args)
{
	int indx;
	char **cmdline;
	int pid;

	if ((cmdline = (char **)malloc((argc + n_input_args + 1) * sizeof(char *))) == 0) {
		return perror("Out of memory"), 1;
	}
	for (indx = 0; indx < argc; ++indx) {
		cmdline[indx] = argv[indx];
		/*printf("TRACE: cmdline[%d]='%s'\n", indx, cmdline[indx]);*/
	}
	while (input_args != 0) {
		cmdline[indx] = input_args->data;
		/*printf("TRACE: cmdline[%d]='%s'\n", indx, cmdline[indx]);*/
		++indx;
		input_args = input_args->next;
	}
	cmdline[indx] = 0;
	switch(pid = fork()) {
	case -1:
		return -1;
	case 0:
		/*printf("TRACE: execv(%d);\n", indx);*/
		execv(cmdline[0], cmdline);
		break;
	default:
		wait(&pid);
		break;
	}
	return 0;
}


main(int argc, char *argv[])
{
	char opt;
	extern int optind;
	int skip_run_if_empty = 0;
	int maxlines = 0;
	int indx;
	int size_cmd;
	char buf[1024];
	llist_t *head = 0, *curnode, *ll;
	int n_inputs;
	char **cmdline;

	while ((opt = getopt(argc, argv, "rL:")) != EOF) {
		switch(opt) {
		case 'r': skip_run_if_empty = 1;
		     break;
		case 'L': maxlines = atoi(optarg);
		     break;
		}
	}

	for (size_cmd = 0, indx = optind; indx < argc; ++indx) { ++size_cmd; }

	n_inputs = 0;
	while (fgets(buf, sizeof(buf), stdin) != (char *)0) {
		++n_inputs;
		if ((ll = malloc(sizeof(llist_t) + strlen(buf))) == 0) {
			perror("Out of memory");
			exit(1);
		}
		int sl = strlen(buf) - 1;
		if (buf[sl] == '\n') buf[sl] = '\0';
		strcpy(ll->data, buf);
		ll->next = 0;
		if (head == 0)
			head = curnode = ll;
		else {
			curnode->next = ll;
			curnode = ll;
		}
		if (maxlines > 0 && n_inputs + size_cmd >= maxlines) {
			do_command(&argv[optind], size_cmd, head, n_inputs);
			curnode = head;
			while (curnode != 0) {
				ll = curnode->next;
				free(curnode);
				curnode = ll;
			}
			head = 0;
			n_inputs = 0;
		}
	}
	if (head == NULL && skip_run_if_empty == 1)
		exit(0);
	else
		exit(do_command(&argv[optind], size_cmd, head, n_inputs));
/*
	if ((cmdline = (char **)malloc(++size_cmdline * sizeof(char *))) == 0) {
		perror("Out of memory");
		exit(1);
	}
	for (indx = optind; indx < argc; ++indx) {
		cmdline[indx - optind] = argv[indx];
	}
	indx -= optind;
	ll = head;
	while (ll != NULL) {
		cmdline[indx++] = ll->data;
		ll = ll->next;
	}
	cmdline[indx] = NULL;

	exit(execv(cmdline[0], cmdline));
*/
}
