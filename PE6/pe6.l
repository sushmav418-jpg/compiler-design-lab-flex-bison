%{
#include "pe6.tab.h"
#include <stdlib.h>
#include <string.h>
%}

%option noyywrap

ID   [a-zA-Z_][a-zA-Z0-9_]*
NUM  [0-9]+

%%

[ \t\n]+      ;

{NUM}         {
                 yylval.str = strdup(yytext);
                 return NUM;
              }

{ID}          {
                 yylval.str = strdup(yytext);
                 return ID;
              }

"+"           return PLUS;
"-"           return MINUS;
"*"           return MUL;
"/"           return DIV;
"="           return ASSIGN;
"("           return LPAREN;
")"           return RPAREN;

.             ;

%%