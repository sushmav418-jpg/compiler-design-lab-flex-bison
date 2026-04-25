%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex();
void yyerror(const char *s);

/* ── Quadruple store ───────────────────────────── */
#define MAX_QUADS 100

typedef struct {
    char op[20];
    char arg1[20];
    char arg2[20];
    char result[20];
} Quad;

Quad quads[MAX_QUADS];
int  quadCount = 0;

/* Store one quadruple (no printing yet) */
void emit(char *op, char *arg1, char *arg2, char *result) {
    if (quadCount >= MAX_QUADS) return;
    strncpy(quads[quadCount].op,     op     ? op     : "_", 19);
    strncpy(quads[quadCount].arg1,   arg1   && strlen(arg1)   ? arg1   : "_", 19);
    strncpy(quads[quadCount].arg2,   arg2   && strlen(arg2)   ? arg2   : "_", 19);
    strncpy(quads[quadCount].result, result && strlen(result) ? result : "_", 19);
    quadCount++;
}

/* Print the full TAC table after parsing */
void printTAC() {
    printf("\n");
    printf("+-----+--------+----------+----------+------------+\n");
    printf("| No. | op     | arg1     | arg2     | result     |\n");
    printf("+-----+--------+----------+----------+------------+\n");
    for (int i = 0; i < quadCount; i++) {
        printf("| %-3d | %-6s | %-8s | %-8s | %-10s |\n",
               i + 1,
               quads[i].op,
               quads[i].arg1,
               quads[i].arg2,
               quads[i].result);
    }
    printf("+-----+--------+----------+----------+------------+\n\n");
}

/* ── Temporary variable generator ─────────────── */
int tempCount = 1;

char* newTemp() {
    char *t = (char*)malloc(10);
    sprintf(t, "t%d", tempCount++);
    return t;
}
%}

%union {
    char *str;
}

%token <str> ID NUM
%token PLUS MINUS MUL DIV ASSIGN LPAREN RPAREN

%type <str> expr

%right ASSIGN
%left  PLUS MINUS
%left  MUL DIV

%%

input:
      ID ASSIGN expr {
            /* final assignment quad: arg2 is empty -> shown as _ */
            emit("=", $3, "", $1);
            printf("\nThree-Address Code (TAC) - Quadruples:");
            printTAC();
            printf("TAC generation complete.\n");
        }
    ;

expr:
      expr PLUS  expr { char *t = newTemp(); emit("+", $1, $3, t); $$ = t; }
    | expr MINUS expr { char *t = newTemp(); emit("-", $1, $3, t); $$ = t; }
    | expr MUL   expr { char *t = newTemp(); emit("*", $1, $3, t); $$ = t; }
    | expr DIV   expr { char *t = newTemp(); emit("/", $1, $3, t); $$ = t; }
    | LPAREN expr RPAREN { $$ = $2; }
    | ID  { $$ = $1; }
    | NUM { $$ = $1; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main() {
    printf("Enter assignment (e.g.  x = a + b * c ): ");
    fflush(stdout);
    yyparse();
    return 0;
}
