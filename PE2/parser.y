%{
#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern int line_no;
extern char *yytext;
extern FILE *yyin;

void yyerror(const char *s);
%}

/* Tokens */
%token ID NUM TYPE
%token IF ELSE DO WHILE
%token RELOP ARITHOP

/* Operator precedence (low → high) */
%right '='
%left RELOP
%left ARITHOP

%%

program
    : statements
    ;

statements
    : statements statement
    | statement
    ;

statement
    : declaration
    | selection_stmt
    | iteration_stmt
    | block
    | expression ';'
    ;

block
    : '{' statements '}'
    ;

declaration
    : TYPE declarator_list ';'
    ;

declarator_list
    : ID
    | declarator_list ',' ID
    ;

selection_stmt
    : IF '(' expression ')' statement
    | IF '(' expression ')' statement ELSE statement
    ;

iteration_stmt
    : DO statement WHILE '(' expression ')' ';'
    ;

expression
    : ID '=' expression
    | expression ARITHOP expression
    | expression RELOP expression
    | '(' expression ')'
    | ID
    | NUM
    ;

%%

/* Error handling */
void yyerror(const char *s) {
    fprintf(stderr,
        "Syntax error at line %d, token '%s': %s\n",
        line_no, yytext, s);
}

int main(int argc, char *argv[]) {
    if (argc > 1) {
        FILE *fp = fopen(argv[1], "r");
        if (!fp) {
            perror("File open failed");
            return 1;
        }
        yyin = fp;
    }

    if (yyparse() == 0) {
        printf("Syntax valid\n");
    }
    return 0;
}
