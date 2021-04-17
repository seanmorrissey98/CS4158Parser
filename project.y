%{

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#define MAX_VARIABLES 100

extern int yylex();
extern int yyparse();
extern int yylineno;
extern FILE* yyin;

char names[MAX_VARIABLES][7];
int sizes[MAX_VARIABLES][2];
int variableTotal = 0;

void yyerror(const char* s);
void defineVariable(char *size, char *name);
bool isDefined(char *name, bool check);
void getSize(char *size);
void defineInt(char *size);
void defineDouble(char *size);
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
definition:			INT_VARIABLE IDENTIFIER SEMICOLON {defineVariable($1, $2);}
					| DOUBLE_VARIABLE IDENTIFIER SEMICOLON {defineVariable($1, $2);}
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
combination:		IDENTIFIER {isDefined($1, true);}
					| IDENTIFIER COMMA combination {isDefined($1, true);}
					| STRING {}
					| STRING COMMA combination {}
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

bool isDefined(char *name, bool check) {
	bool defined = false;
	for(int i = 0; i < variableTotal; i++) {
		if(strcmp(names[i], name) == 0) {
			defined = true;
		}
	}
	if(defined == false && check == true) {
		printf("%s is not defined\n", name);
	}
	return defined;
}

void defineVariable(char *size, char *name) {
	printf("SIZE: %s\n", size);
	printf("NAME: %s\n", size);
	if(isDefined(name, false) == true) {
		printf("Already defined");
	}
	strcpy(names[variableTotal], name);
	getSize(size);
	variableTotal = variableTotal + 1;
}

void getSize(char *size) {
	if(strchr(size, '-') != NULL) {
		defineDouble(size);
	} else {
		defineInt(size);
	}
}

void defineInt(char *size) {
	int length = 0;
	while(size != NULL && *size != '\0') {
		length++;
		++size;
	}
	printf("length: %d\n", length);
	sizes[variableTotal][0] = length;
	sizes[variableTotal][1] = 0;
}

void defineDouble(char *size) {
	int integerLength = 0;
	int decimalLength = 0;
	int totalLength = 0;
	int index = 0;
	while(size != NULL && *size != '\0') {
		totalLength++;
		++size;
	}
	char *location;
	location = strchr(size, '-');
	index = atoi(location);
	integerLength = index - 1;
	decimalLength = totalLength - index;
	sizes[variableTotal][0] = integerLength;
	sizes[variableTotal][1] = decimalLength;
}