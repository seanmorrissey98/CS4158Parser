%{

#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern int yyparse();
extern FILE* yyin;

void yyerror(const char* s);
%}

%union {
	char *id;
	int ival;
	float fval;
}

%token<ival> NUMERIC_INT
%token<fval> NUMERIC_DOUBLE
%token<id> IDENTIFIER
%token<id> INT_VARIABLE
%token<id> DOUBLE_VARIABLE
%token ADD TO MAIN END START PRINT INPUT EQUALS_TO EQUALS_TO_VALUE 
%token STRING SEMICOLON COMMA INVALID

%start start_program

%%

start_program:		START SEMICOLON variables {}
variables:			definition variables {}
					| main {}
definition:			variable IDENTIFIER SEMICOLON {}
variable:			INT_VARIABLE | DOUBLE_VARIABLE {}
main:				MAIN SEMICOLON statements {}
statements:			keyword statements {}
					| finish {}
keyword:			print {}
					| add {}
					| input {}
					| check_equals {}
input:				INPUT readin SEMICOLON {}
readin:				IDENTIFIER COMMA readin {}
					| IDENTIFIER {}
add:				ADD type TO IDENTIFIER SEMICOLON {}
type:				IDENTIFIER {}
					| NUMERIC_INT {}
					| NUMERIC_DOUBLE {}
print:				PRINT combination SEMICOLON {}
combination:		IDENTIFIER {}
					| IDENTIFIER COMMA {}
					| STRING {}
					| STRING COMMA {}
check_equals:		IDENTIFIER EQUALS_TO IDENTIFIER SEMICOLON {}
					| IDENTIFIER EQUALS_TO_VALUE NUMERIC_INT SEMICOLON {}
					| IDENTIFIER EQUALS_TO_VALUE NUMERIC_DOUBLE SEMICOLON {}
finish:				END SEMICOLON {exit(0);}

%%

int main() {
	yyin = stdin;

	do {
		yyparse();
	} while(!feof(yyin));

	return 0;
}

void yyerror(const char* s) {
	fprintf(stderr, "Parse error: %s\n", s);
	exit(1);
}