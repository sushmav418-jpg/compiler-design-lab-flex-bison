%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex();
void yyerror(const char *s);

/* ── Symbol Table ──────────────────────────────── */
struct Symbol {
    char name[50];
    int  value;
    int  declared;   /* 1 = set at least once */
} table[100];

int symCount = 0;
int errorFlag = 0;   /* set to 1 on any error so we skip symbol table */

/* ── Look up a variable (read) ─────────────────── */
int getValue(char *name) {
    for (int i = 0; i < symCount; i++) {
        if (strcmp(table[i].name, name) == 0)
            return table[i].value;
    }
    printf("\n  [ERROR] Variable '%s' not declared!\n", name);
    fflush(stdout);
    errorFlag = 1;
    return 0;   /* recover: return 0 and keep parsing */
}

/* ── Assign / update a variable ────────────────── */
void setValue(char *name, int val) {
    for (int i = 0; i < symCount; i++) {
        if (strcmp(table[i].name, name) == 0) {
            table[i].value    = val;
            table[i].declared = 1;
            printf("  Assigned : %s = %d\n", name, val);
            fflush(stdout);
            return;
        }
    }
    /* new entry */
    strcpy(table[symCount].name, name);
    table[symCount].value    = val;
    table[symCount].declared = 1;
    symCount++;
    printf("  Assigned : %s = %d\n", name, val);
    fflush(stdout);
}

/* ── Print symbol table ────────────────────────── */
void printSymbolTable() {
    printf("\n+----------------------+----------+\n");
    printf("| Variable             | Value    |\n");
    printf("+----------------------+----------+\n");
    for (int i = 0; i < symCount; i++) {
        printf("| %-20s | %-8d |\n", table[i].name, table[i].value);
    }
    printf("+----------------------+----------+\n\n");
}
%}

%union {
    int   ival;
    char *sval;
}

%token <ival> NUMBER
%token <sval> ID
%token PLUS MINUS MUL DIV ASSIGN COMMA LPAREN RPAREN

%type <ival> expr

%left PLUS MINUS
%left MUL DIV

%%

input:
      stmt_list
    ;

stmt_list:
      stmt
    | stmt_list COMMA stmt
    ;

stmt:
      ID ASSIGN expr {
            setValue($1, $3);
        }
    ;

expr:
      expr PLUS  expr   { $$ = $1 + $3; }
    | expr MINUS expr   { $$ = $1 - $3; }
    | expr MUL   expr   { $$ = $1 * $3; }
    | expr DIV   expr   {
            if ($3 == 0) {
                printf("\n  [ERROR] Division by zero detected!  (%d / 0)\n", $1);
                fflush(stdout);
                errorFlag = 1;
                $$ = 0;   /* recover: treat result as 0, keep parsing */
            } else {
                $$ = $1 / $3;
            }
        }
    | LPAREN expr RPAREN { $$ = $2; }
    | NUMBER             { $$ = $1; }
    | ID                 { $$ = getValue($1); }
    ;

%%

void yyerror(const char *s) {
    printf("\n  [ERROR] Parse error: %s\n", s);
    fflush(stdout);
    errorFlag = 1;
}

int main() {
    printf("========================================\n");
    printf("   PE4 - Expression Evaluator\n");
    printf("   Input format: a=10, b=20, c=a+b\n");
    printf("========================================\n");
    printf("Enter statements: ");
    fflush(stdout);

    yyparse();

    if (errorFlag) {
        printf("\n  [!] Errors occurred during evaluation.\n");
    }

    printf("\n--- Symbol Table ---");
    if (symCount == 0)
        printf("\n  (empty)\n\n");
    else
        printSymbolTable();

    return 0;
}
