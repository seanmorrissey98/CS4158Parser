/* Headers, declarations */
%{
    #include <stdio.h>
%}

/* Token Specification */
%%
[\t\n ]+                        ;
[xX]+                           {printf("Int Token \n");};
[xX]+[\-][xX]+                  {printf("Double Token\n");};
(?i:ADD)                        {printf("Add Token \n");};
(?i:TO)                         {printf("To Token \n");};
(?i:MAIN)                       {printf("Main Token \n");};
(?i:END)                        {printf("End Token \n");};
(?i:START)                      {printf("Start Token \n");};
(?i:PRINT)                      {printf("Print Token \n");};
(?i:EQUALS\-TO)                 {printf("Equals-to Token \n");};
(?i:EQUALS\-TO\-VALUE)          {printf("Equals-to-value Token \n");};
[0-9]+                          {printf("Numeric Int Token\n");};
[0-9]+\.[0-9]+|\.[0-9]+         {printf("Numeric Double Token\n");};
[a-zA-Z0-9]{1,6}                {printf("Identifier Token \n");};
\"([^"\\])*\"                   {printf("String Token \n");};
\;                              {printf("Semicolon Token \n");};
\,                              {printf("Comma Token \n");};
.|[a-zA-Z0-9]{7,}               {printf("Does not match \n");};
%%

int main() {
    yylex();
}
int yywrap() { 
    return 1;
}