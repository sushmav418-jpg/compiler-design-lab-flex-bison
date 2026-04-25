%{
#include <stdio.h>
#include <string.h>

/* ── Token counters ─────────────────────── */
int cnt_keyword    = 0;
int cnt_identifier = 0;
int cnt_int_const  = 0;
int cnt_float_const= 0;
int cnt_char_const = 0;
int cnt_string     = 0;
int cnt_operator   = 0;
int cnt_punctuator = 0;
int cnt_unknown    = 0;
int total          = 0;

void print_token(const char *type, const char *lexeme) {
    printf("%-20s : %s\n", type, lexeme);
    total++;
}
%}

/* -------- DEFINITIONS -------- */

KEYWORD     auto|break|case|char|const|continue|default|do|double|else|enum|extern|float|for|goto|if|int|long|register|return|short|signed|sizeof|static|struct|switch|typedef|union|unsigned|void|volatile|while

IDENTIFIER  [a-zA-Z_][a-zA-Z0-9_]*

INT_CONST   [0-9]+
FLOAT_CONST ([0-9]*\.[0-9]+)|([0-9]+\.[0-9]*)

CHAR_CONST  \'([^\\\n]|(\\.))\'
STRING      \"([^\\\n]|(\\.))*\"

OPERATOR    \+\+|--|==|!=|<=|>=|&&|\|\||<<|>>|[-+*/%=&|^!<>~]

PUNCTUATOR  [()\[\]{};,.:?]

WHITESPACE  [ \t\r\n]+

COMMENT1    \/\/.*
COMMENT2    \/\*([^*]|\*+[^*/])*\*+\/

%%

{WHITESPACE}   ;
{COMMENT1}     ;
{COMMENT2}     ;

{KEYWORD}      { cnt_keyword++;     print_token("KEYWORD",        yytext); }
{FLOAT_CONST}  { cnt_float_const++; print_token("FLOAT_CONST",    yytext); }
{INT_CONST}    { cnt_int_const++;   print_token("INT_CONST",       yytext); }
{CHAR_CONST}   { cnt_char_const++;  print_token("CHAR_CONST",      yytext); }
{STRING}       { cnt_string++;      print_token("STRING_LITERAL",  yytext); }
{IDENTIFIER}   { cnt_identifier++;  print_token("IDENTIFIER",      yytext); }
{OPERATOR}     { cnt_operator++;    print_token("OPERATOR",        yytext); }
{PUNCTUATOR}   { cnt_punctuator++;  print_token("PUNCTUATOR",      yytext); }
.              { cnt_unknown++;     print_token("UNKNOWN",         yytext); }

%%

int yywrap() { return 1; }

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *fp = fopen(argv[1], "r");
        if (!fp) { perror("Cannot open file"); return 1; }
        yyin = fp;
    }

    printf("%-20s : %s\n", "TOKEN TYPE", "LEXEME");
    printf("---------------------------------------------\n");

    yylex();

    /* ── Summary Table ──────────────────────── */
    printf("\n=============================================\n");
    printf("         TOKEN COUNT SUMMARY\n");
    printf("=============================================\n");
    printf("  %-20s : %d\n", "Keywords",          cnt_keyword);
    printf("  %-20s : %d\n", "Identifiers",       cnt_identifier);
    printf("  %-20s : %d\n", "Integer Constants", cnt_int_const);
    printf("  %-20s : %d\n", "Float Constants",   cnt_float_const);
    printf("  %-20s : %d\n", "Char Constants",    cnt_char_const);
    printf("  %-20s : %d\n", "String Literals",   cnt_string);
    printf("  %-20s : %d\n", "Operators",         cnt_operator);
    printf("  %-20s : %d\n", "Punctuators",       cnt_punctuator);
    if (cnt_unknown > 0)
    printf("  %-20s : %d\n", "Unknown",           cnt_unknown);
    printf("---------------------------------------------\n");
    printf("  %-20s : %d\n", "TOTAL TOKENS",      total);
    printf("=============================================\n\n");

    return 0;
}
