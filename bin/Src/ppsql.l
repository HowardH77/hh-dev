static char rev[] = "#(@) $Id: ppsql.l,v 1.8 2005/04/28 13:48:55 howard Exp $";
/* Synsopsis     ppsql [file_containing_SQL_statement ...]
 * Description:  A simple SQL Pretty Printer
 */

%{
#include <stdio.h>
#include <string.h>

enum {
	TOKEN_SELECT = 1,
	TOKEN_IDENTIFIER,
	TOKEN_COMMA,
	TOKEN_FROM,
	TOKEN_WHERE,
	TOKEN_AND,
	TOKEN_OR,
	TOKEN_OPAREN,
	TOKEN_CPAREN,
	TOKEN_STRING,
	TOKEN_INTEGER,
	TOKEN_DOUBLE,
	TOKEN_OPERATOR,
        N_TOKENS
};
%}
%option noyywrap

%%

select                  { return TOKEN_SELECT; }
","                     { return TOKEN_COMMA; }
\".*\"                  { return TOKEN_STRING; }
\'.*\'                  { return TOKEN_STRING; }
[0-9]+                  { return TOKEN_INTEGER; }
[0-9]+"."[0-9]*         { return TOKEN_DOUBLE; }
from                    { return TOKEN_FROM; }
where                   { return TOKEN_WHERE; }
and                     { return TOKEN_AND; }
or                      { return TOKEN_OR; }
"("                     { return TOKEN_OPAREN; }
")"                     { return TOKEN_CPAREN; }
[a-zA-Z][a-zA-Z0-9_.]*  { return TOKEN_IDENTIFIER; }
"+"|"-"|"*"|"/"|"="|"<>"|"!="|">"|"<"|"<="|">="    {
                        return TOKEN_OPERATOR; }

[ \t\n]+                /* Eat Whitespace */

.                       printf("?%c?", yytext[0] );   /* Hmmm, what's this? */

%%
typedef enum {
	BEGIN_STATE,
	PARSE_SELECT,
	PARSE_FROM,
	PARSE_WHERE,
	END_STATE,
} parse_state;

typedef struct int_stack_s {
	int size;
	int top;
	int stack[1];  /*  Actually int stack[size];   ref: new_int_stack()  */
} int_stack_t;


int_stack_t *
new_int_stack(int size)
{
	int_stack_t *stack;

	if (stack = malloc(sizeof(int_stack_t) + (size - 1) * sizeof(int))) {
		stack->size = size;
		stack->top = 0;
	}
	return stack;
}


static int
push(int_stack_t *stack, int val)
{
	if (stack->top < stack->size) {
		stack->stack[stack->top++] = val;
		return stack->top;
	}
	return -1;
}


static int
pop(int_stack_t *stack, int *val) 
{
	if (stack->top > 0) {
		*val = stack->stack[--stack->top];
		return stack->top;
	}
	return -1;
}


ppsql(FILE *fp_in)
{
	int_stack_t *indent_stack = new_int_stack(255);
	parse_state state;
	int token_type, space_flag;
	int indent = 0, col = 0;

	yyin = fp_in;
	state = BEGIN_STATE;

	while (token_type = yylex()) {
		switch(token_type) {
		case TOKEN_SELECT:
			fputs("select ", stdout);
			indent = col;
			col += 7;
                        space_flag = 0;
			state = PARSE_SELECT;
			break;
		case TOKEN_FROM:
		case TOKEN_WHERE:
		case TOKEN_AND:
		case TOKEN_OR:
			fputc('\n', stdout);
			for (col = 0; col < indent; ++col) { fputc(' ', stdout); }
			if (col == 0) {
				if (token_type == TOKEN_AND) {
					fputs("  ", stdout);
					col += 2;
				} else if (token_type == TOKEN_OR) {
					fputs("   ", stdout);
					col += 3;
				}
			}
			fputs(yytext, stdout);
			fputc(' ', stdout);
			col += (strlen(yytext) + 1);
			space_flag = 0;
			break;
		case TOKEN_OPAREN:
			if (space_flag) { fputc(' ', stdout); }
			push(indent_stack, indent);
			fputs("( ", stdout);
			col += (2 + space_flag);
			indent = col;
			space_flag = 0;
			break;
		case TOKEN_CPAREN:
			fputs(" )", stdout);
			col += 2;
			pop(indent_stack, &indent); 
			space_flag = 1;
			break;
		case TOKEN_COMMA:
			/*fputs(((state == PARSE_SELECT) ? ",\n" : ", "), stdout);*/
			fputs(", ", stdout);
			col += 2;
			space_flag = 0;
			break;
		case TOKEN_OPERATOR:
			fputc(' ', stdout);
			fputs(yytext, stdout);
			fputc(' ', stdout);
			col += (strlen(yytext) + 2);
			space_flag = 0;
			break;
		default:
			if (space_flag) { fputc(' ', stdout); }
			fputs(yytext, stdout);
			col += (strlen(yytext) + space_flag);
			space_flag = 1;
			break;
		}
	}
	printf("\n");
	return 0;
}


main( argc, argv )
int argc;
char **argv;
{
	int retcode;

	if (argc == 1) {
		retcode = ppsql(stdin);
	} else {
		int indx;
		FILE *fp;
		for (indx = 1; indx < argc; ++indx) {
			if (fp = fopen(argv[indx], "r")) {
				if (argc > 2) { printf("=== %s ===\n", argv[indx]); }
				retcode = ppsql(fp);
				fclose(fp);
				if (retcode != 0)
					break;
			}
		}
	}
	return retcode;
}


/*
:!lex % && cc -g lex.yy.c && rm -f lex.yy.c
:!echo 'select col1, string, (a+b)/c, literal from table , table2 where x = y and a = b or  c in (select distinct abc from def where alphabet = 1) and 1 =  1' | a.out

Sample SQL:
select distinct tran_schedule_delivery.  delivery_id, 455854
from tran_schedule_delivery, ab_tran, schedule_delivery_detail
where ( tran_schedule_delivery.delivery_id = schedule_delivery_detail.delivery_id
        and schedule_delivery_detail.deal_tracking_num = ab_tran.deal_tracking_num )
  and ( tran_schedule_delivery.volume_type <> 0
        and ( ( ab_tran.ins_type in ( select id_number
                                      from instruments
                                      where id_number in ( 45001, 45002, 45006, 45149, 45160 )
                                         or base_ins_id in ( 45001, 45002, 45006, 45149, 45160 ) )
                and ab_tran.buy_sell = 0 )
           or ( ab_tran.ins_type in ( select id_number
                                      from instruments
                                      where id_number in ( 45003, 45008, 45137, 45146 )
                                         or base_ins_id in ( 45003, 45008, 45137, 45146 ) ) )
           or ( ab_tran.ins_type in ( select id_number
                                      from instruments
                                      where id_number in ( 45001, 45002, 45006, 45149, 45160 )
                                         or base_ins_id in ( 45001, 45002, 45006, 45149, 45160 ) )
                and ab_tran.buy_sell = 1 ) )
        and tran_schedule_delivery.gmt_start_date_time < '01-mar-2004 00:00:00'
        and tran_schedule_delivery.gmt_end_date_time > '01-jan-2003 00:00:00'
        and tran_schedule_delivery.volume_type in ( 4 , 6 ) )
  or not exists ( select *
                  from query_result qr2
                  where qr2.unique_id = 455854
                    and qr2.query_result = tran_schedule_delivery.delivery_id )
*/
