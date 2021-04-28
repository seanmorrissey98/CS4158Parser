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

// 8 in length to take care of '\0'
char names[MAX_VARIABLES][8];
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
add:				ADD IDENTIFIER TO IDENTIFIER SEMICOLON {if(isDefined($4, true) && isDefined($2, true)) {checkEqualsIdentifier($4, $2);};}
					| ADD NUMERIC_INT TO IDENTIFIER SEMICOLON {if(isDefined($4, true)) {checkEqualsInt($4, $2);};}
					| ADD NUMERIC_DOUBLE TO IDENTIFIER SEMICOLON {if(isDefined($4, true)) {checkEqualsDouble($4, $2);};}
print:				PRINT combination SEMICOLON {}
combination:		IDENTIFIER {isDefined($1, true);}
					| IDENTIFIER COMMA combination {isDefined($1, true);}
					| STRING {}
					| STRING COMMA combination {}
check_equals:		IDENTIFIER EQUALS_TO IDENTIFIER SEMICOLON {if(isDefined($1, true) && isDefined($3, true)) {checkEqualsIdentifier($1, $3);};}
					| IDENTIFIER EQUALS_TO_VALUE NUMERIC_INT SEMICOLON {if(isDefined($1, true)) {checkEqualsInt($1, $3);};}
					| IDENTIFIER EQUALS_TO_VALUE NUMERIC_DOUBLE SEMICOLON {if(isDefined($1, true)) {checkEqualsDouble($1, $3);};}
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
	fprintf(stderr, "Parse error (Line: %d): %s\n", yylineno, s);
	exit(1);
}

/*
 * Checks to see if an identifier is declared
 * Returns true if it is defined
 * Returns false if it isnt defined
 */
bool isDefined(char *name, bool check) {
	bool defined = false;
	for(int i = 0; i < variableTotal; i++) {
		if(strcmp(names[i], name) == 0) {
			defined = true;
		}
	}
	if(defined == false && check == true) {
		printf("Warning: %s is not declared (Line %d)\n", name, yylineno);
	}
	return defined;
}

/*
 * Checks if a identifier is already declared
 * If its not then we define it
 */
void defineVariable(char *size, char *name) {
	if(isDefined(name, false) == true) {
		printf("Warning: %s is already declared (Line %d)\n", name, yylineno);
		return;
	}
	strcpy(names[variableTotal], name);
	getSize(size);
	variableTotal = variableTotal + 1;
}

/*
 * Checks if the identifier contains a '-' i.e. XX-XX
 * If it does we define a double identifier
 * If it does not we define an int
 */
void getSize(char *size) {
	if(strchr(size, '-') != NULL) {
		defineDouble(size);
	} else {
		defineInt(size);
	}
}

/*
 * Defines an int identifier into the size table
 */
void defineInt(char *size) {
	int length = 0;
	while(size != NULL && *size != '\0') {
		length++;
		++size;
	}
	sizes[variableTotal][0] = length;
	sizes[variableTotal][1] = 0;
}

/*
 * Defines a double identifier into the size table
 */
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

/*
 * Checks if an identifiers size matches an int
 */
void checkEqualsInt(char *identifier, int literal) {
	int inetegerSize1, doubleSize1, index1, literalSize;
	inetegerSize1 = 0;
	doubleSize1 = index1 = literalSize = inetegerSize1;
	
	literalSize = floor(log10(abs(literal))) + 1;
	index1 = getIndex(identifier);
	
	inetegerSize1 = sizes[index1][0];
	doubleSize1 = sizes[index1][1];
	
	if(inetegerSize1 != literalSize || doubleSize1 != 0) {
		printf("Warning: %s is not the same size as %d (Line %d)\n", identifier, literal, yylineno);
		printf("Warning: %s is size %d-%d\n", identifier, inetegerSize1, doubleSize1);
		printf("Warning: %d is size %d-%d\n", literal, literalSize, 0);
	}
}

/*
 * Checks if an identifiers size matches another identifier
 */
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
		printf("Warning: %s is not the same size as %s (Line %d)\n", identifier1, identifier2, yylineno);
		printf("Warning: %s is size %d-%d\n", identifier1, inetegerSize1, doubleSize1);
		printf("Warning: %s is size %d-%d\n", identifier2, inetegerSize2, doubleSize2);
	}
}

/*
 * Checks if an identifiers size matches a double
 */
void checkEqualsDouble(char *identifier, char *literal) {
	int inetegerSize1, doubleSize1, index1, literalSize1, literalSize2;
	inetegerSize1 = 0;
	doubleSize1 = index1 = literalSize1 = literalSize2 = inetegerSize1;
	
	index1 = getIndex(identifier);
	getLiteralFloatSize(&literalSize1, &literalSize2, literal);

	inetegerSize1 = sizes[index1][0];
	doubleSize1 = sizes[index1][1];

	if(inetegerSize1 != literalSize1 || doubleSize1 != literalSize2) {
		printf("Warning: %s is not the same size as %s (Line %d)\n", identifier, literal, yylineno);
		printf("Warning: %s is size %d-%d\n", identifier, inetegerSize1, doubleSize1);
		printf("Warning: %s is size %d-%d\n", literal, literalSize1, literalSize2);
	}
}

/*
 * Gets the index of an identifier in the name and size table
 */
int getIndex(char *identifier) {
	int index1 = 0;
	for(int i = 0; i < variableTotal; i++) {
		if(strcmp(names[i], identifier) == 0) {
			index1 = i;
		}
	}
	return index1;
}

/*
 * Gets the size of a literal float i.e. 12.14 is 2-2
 */
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