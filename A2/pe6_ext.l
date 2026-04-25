%{
#include "pe6_ext.tab.h"
#include <string.h>
%}

%option noyywrap

ID [a-zA-Z_][a-zA-Z0-9_]*

%%

"if"        return IF;
"else"      return ELSE;
"do"        return DO;
"while"     return WHILE;

"<="        return LE;
">="        return GE;
"=="        return EQ;
"!="        return NE;
"<"         return LT;
">"         return GT;

"="         return ASSIGN;
"+"         return PLUS;
"*"         return MUL;

"("         return LPAREN;
")"         return RPAREN;
"{"         return LBRACE;
"}"         return RBRACE;
";"         return SEMI;

{ID}        {
               yylval.str = strdup(yytext);
               return ID;
            }

[ \t\n]+    ;

.           ;

%%