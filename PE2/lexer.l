%{
#include "parser.tab.h"
int line_no = 1;
%}

%%

int|float|char|double   { return TYPE; }

if      { return IF; }
else    { return ELSE; }
do      { return DO; }
while   { return WHILE; }

==|!=|<=|>=|<|>         { return RELOP; }
[+\-*/]                { return ARITHOP; }

";"     { return ';'; }
","     { return ','; }
"("     { return '('; }
")"     { return ')'; }
"{"     { return '{'; }
"}"     { return '}'; }

[0-9]+                  { return NUM; }
[a-zA-Z_][a-zA-Z0-9_]*  { return ID; }

[ \t\r]+               ;
\n                      { line_no++; }

.                       { return yytext[0]; }

%%

int yywrap(void)
{
    return 1;
}
