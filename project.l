/* Headers, declarations */
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "y.tab.h"
%}

/* Token Specification */
%%
[\t\n ]+                                                ;
[xX]+                                                   {yylval.id = yytext; return INT_VARIABLE;};
[xX]+[\-][xX]+                                          {yylval.id = yytext; return DOUBLE_VARIABLE;};
(?i:ADD)                                                {return ADD;};
(?i:TO)                                                 {return TO;};
(?i:MAIN)                                               {return MAIN;};
(?i:END)                                                {return END;};
(?i:START)                                              {return START;};
(?i:PRINT)                                              {return PRINT;};
(?i:INPUT)                                              {return INPUT;};
(?i:EQUALS\-TO)                                         {return EQUALS_TO;};
(?i:EQUALS\-TO\-VALUE)                                  {return EQUALS_TO_VALUE;};
[0-9]+                                                  {yylval.ival = atoi(yytext); return NUMERIC_INT;};
[0-9]+\.[0-9]+|\.[0-9]+                                 {yylval.fval = atof(yytext); return NUMERIC_DOUBLE;};
[a-zA-Z][a-zA-Z0-9]{0,4}[a-zA-Z]|[a-wy-zA-WY-Z]         {yylval.id = yytext; return IDENTIFIER;};
\"([^"\\])*\"                                           {return STRING;};
\;                                                      {return SEMICOLON;};
\,                                                      {return COMMA;};
.|[0-9][a-zA-Z0-9]+|[a-zA-Z0-9]+[0-9]|\-[a-zA-Z0-9]+    {return INVALID;};
%%

int main() {
    yylex();
}
int yywrap() { 
    return 1;
}