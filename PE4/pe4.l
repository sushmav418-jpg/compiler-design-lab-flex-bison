%{
#include "pe4.tab.h"
#include <stdlib.h>
#include <string.h>
%}

%option noyywrap

DIGIT  [0-9]
ID     [a-zA-Z_][a-zA-Z0-9_]*

%%

[ \t\r\n]+      ;

{DIGIT}+        {
                    yylval.ival = atoi(yytext);
                    return NUMBER;
                }

{ID}            {
                    yylval.sval = strdup(yytext);
                    return ID;
                }

","             return COMMA;
"="             return ASSIGN;
"+"             return PLUS;
"-"             return MINUS;
"*"             return MUL;
"/"             return DIV;
"("             return LPAREN;
")"             return RPAREN;

.               ;

%%
