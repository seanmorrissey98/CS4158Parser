%{

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <math.h>
#define MAX_VARIABLES 100

extern int yylex();
extern int yyparse();
extern int yylineno;
extern FILE* yyin;

char names[MAX_VARIABLES][9];
int sizes[MAX_VARIABLES][2];
int variableTotal = 0;

void yyerror(const char* s);
void defineVariable(char *size, char *name);
bool isDefined(char *name, bool check);
void getSize(char *size);
void defineInt(char *size);
void defineDouble(char *size);
void checkEqualsInt(char *identifier, int literal);
void checkEqualsIdentifier(char *identifier1, char* identifier2);
void checkEqualsDouble(char *identifier, char *literal);
int getIndex(char *identifier);
void getLiteralFloatSize(int *intSize, int *floatSize, char *literal);
%}

%union {
	char *id;
	int ival;
}

%token<ival> NUMERIC_INT
%token<id> NUMERIC_DOUBLE
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
readin:				IDENTIFIER COMMA readin {isDefined($1, true);}
					| IDENTIFIER {isDefined($1, true);}
add:				ADD type TO IDENTIFIER SEMICOLON {isDefined($4, true);}
type:				IDENTIFIER {isDefined($1, true);}
					| NUMERIC_INT {}
					| NUMERIC_DOUBLE {}
print:				PRINT combination SEMICOLON {}
combination:		IDENTIFIER {isDefined($1, true);}
					| IDENTIFIER COMMA combination {isDefined($1, true);}
					| STRING {}
					| STRING COMMA combination {}
check_equals:		IDENTIFIER EQUALS_TO IDENTIFIER SEMICOLON {isDefined($1, true); isDefined($3, true); checkEqualsIdentifier($1, $3);}
					| IDENTIFIER EQUALS_TO_VALUE NUMERIC_INT SEMICOLON {isDefined($1, true); checkEqualsInt($1, $3);}
					| IDENTIFIER EQUALS_TO_VALUE NUMERIC_DOUBLE SEMICOLON {isDefined($1, true); checkEqualsDouble($1, $3);}
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
		printf("%s is not declared\n", name);
	}
	return defined;
}

void defineVariable(char *size, char *name) {
	if(isDefined(name, false) == true) {
		printf("Already declared");
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
	sizes[variableTotal][0] = length;
	sizes[variableTotal][1] = 0;
}

void defineDouble(char *size) {
	int integerLength = 0;
	int decimalLength = 0;
	int index = 0;
	int length = (int)strlen(size);
    for (int i = 0; i < length; i++) 
    {
       if(size[i]=='-') {
		   index = i;
		   break;
	   }
    }
	integerLength = index;
	decimalLength = length - index - 1;
	sizes[variableTotal][0] = integerLength;
	sizes[variableTotal][1] = decimalLength;
}

void checkEqualsInt(char *identifier, int literal) {
	int inetegerSize1, doubleSize1, index1, literalSize;
	inetegerSize1 = 0;
	doubleSize1 = index1 = literalSize = inetegerSize1;
	
	literalSize = floor(log10(abs(literal))) + 1;
	index1 = getIndex(identifier);
	
	inetegerSize1 = sizes[index1][0];
	doubleSize1 = sizes[index1][1];
	
	if(inetegerSize1 != literalSize || doubleSize1 != 0) {
		printf("%s is not the same size as %d\n", identifier, literal);
	}
}

void checkEqualsIdentifier(char *identifier1, char* identifier2) {
	int inetegerSize1, inetegerSize2, doubleSize1, doubleSize2, index1, index2;
	inetegerSize1 = 0;
	index1, index2, inetegerSize2 = doubleSize1 = doubleSize2 = inetegerSize1;
	
	index1 = getIndex(identifier1);
	index2 = getIndex(identifier2);
	
	inetegerSize1 = sizes[index1][0];
	doubleSize1 = sizes[index1][1];
	inetegerSize2 = sizes[index2][0];
	doubleSize2 = sizes[index2][1];
	
	if(inetegerSize1 != inetegerSize2 || doubleSize1 != doubleSize2) {
		printf("%s is not the same size as %s\n", identifier1, identifier2);
	}
}

void checkEqualsDouble(char *identifier, char *literal) {
	int inetegerSize1, doubleSize1, index1, literalSize1, literalSize2;
	inetegerSize1 = 0;
	doubleSize1 = index1 = literalSize1 = literalSize2 = inetegerSize1;
	
	index1 = getIndex(identifier);
	getLiteralFloatSize(&literalSize1, &literalSize2, literal);

	inetegerSize1 = sizes[index1][0];
	doubleSize1 = sizes[index1][1];

	if(inetegerSize1 != literalSize1 || doubleSize1 != literalSize2) {
		printf("%s is not the same size as %s\n", identifier, literal);
	}
}

int getIndex(char *identifier) {
	int index1 = 0;
	for(int i = 0; i < variableTotal; i++) {
		if(strcmp(names[i], identifier) == 0) {
			index1 = i;
		}
	}
	return index1;
}

void getLiteralFloatSize(int *intSize, int *floatSize, char *literal) {
	int length = (int)strlen(literal);
	int index = 0;
    for (int i = 0; i < length; i++) 
    {
       if(literal[i]=='.') {
		   index = i;
		   break;
	   }
    }
	*intSize = index;
	*floatSize = length - index - 1;
}