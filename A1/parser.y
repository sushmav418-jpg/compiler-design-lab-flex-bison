%{
#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern int line_no;
extern char *yytext;
extern FILE *yyin;

void yyerror(const char *s);
%}

/* ---------------- TOKENS ---------------- */
%token ID NUM TYPE
%token IF ELSE DO WHILE FOR
%token SWITCH CASE DEFAULT BREAK
%token RELOP ARITHOP

/* ------------- PRECEDENCE -------------- */
/* lowest → highest */
%right '='
%left RELOP
%left ARITHOP

%%

/* ---------------- PROGRAM ---------------- */

program
    : statements
    ;

statements
    : statements statement
    | statement
    ;

/* ---------------- STATEMENTS ---------------- */

statement
    : declaration
    | selection_stmt
    | iteration_stmt
    | for_stmt
    | switch_stmt
    | block
    | expression ';'
    | BREAK ';'
    ;

block
    : '{' statements '}'
    ;

/* ---------------- DECLARATIONS ---------------- */

declaration
    : TYPE declarator_list ';'
    ;

declarator_list
    : declarator
    | declarator_list ',' declarator
    ;

declarator
    : ID
    | ID '=' expression
    | ID array_dims
    | ID array_dims '=' expression
    ;

array_dims
    : '[' NUM ']'
    | array_dims '[' NUM ']'
    ;

/* ---------------- CONTROL STATEMENTS ---------------- */

selection_stmt
    : IF '(' expression ')' statement
    | IF '(' expression ')' statement ELSE statement
    ;

iteration_stmt
    : DO statement WHILE '(' expression ')' ';'
    | WHILE '(' expression ')' statement
    ;

for_stmt
    : FOR '(' expression ';' expression ';' expression ')' statement
    ;

switch_stmt
    : SWITCH '(' expression ')' '{' case_list '}'
    ;

case_list
    : case_list case_stmt
    | case_stmt
    ;

case_stmt
    : CASE NUM ':' statements
    | DEFAULT ':' statements
    ;

/* ---------------- EXPRESSIONS ---------------- */

expression
    : ID '=' expression
    | expression ARITHOP expression
    | expression RELOP expression
    | '(' expression ')'
    | ID
    | NUM
    ;

%%

/* ---------------- ERROR HANDLING ---------------- */

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