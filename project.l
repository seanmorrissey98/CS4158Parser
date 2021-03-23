/* Headers, declarations */
%{
    #include <stdio.h>
%}

/* Token Specification */
%%
[\t\n ]+                                        ;
[xX]+                                           {printf("%s is a Int variable Token \n", yytext);};
[xX]+[\-][xX]+                                  {printf("%s is a Double variable Token\n", yytext);};
(?i:ADD)                                        {printf("%s is a Add Token \n", yytext);};
(?i:TO)                                         {printf("%s is a To Token \n", yytext);};
(?i:MAIN)                                       {printf("%s is a Main Token \n", yytext);};
(?i:END)                                        {printf("%s is a End Token \n", yytext);};
(?i:START)                                      {printf("%s is a Start Token \n", yytext);};
(?i:PRINT)                                      {printf("%s is a Print Token \n", yytext);};
(?i:INPUT)                                      {printf("%s is a Input Token \n", yytext);};
(?i:EQUALS\-TO)                                 {printf("%s is a Equals-to Token \n", yytext);};
(?i:EQUALS\-TO\-VALUE)                          {printf("%s is a Equals-to-value Token \n", yytext);};
[0-9]+                                          {printf("%s is a Numeric Int Token\n", yytext);};
[0-9]+\.[0-9]+|\.[0-9]+                         {printf("%s is a Numeric Double Token\n", yytext);};
[a-zA-Z][a-zA-Z0-9]{0,4}[a-zA-Z]|[a-wy-zA-WY-Z] {printf("%s is a Identifier Token \n", yytext);};
\"([^"\\])*\"                                   {printf("%s is a String Token \n", yytext);};
\;                                              {printf("%s is a Semicolon Token \n", yytext);};
\,                                              {printf("%s is a Comma Token \n", yytext);};
.|[0-9][a-zA-Z0-9]+|[a-zA-Z0-9]+[0-9]|\-[xX]+   {printf("%s does not match \n", yytext);};
%%

int main() {
    yylex();
}
int yywrap() { 
    return 1;
}