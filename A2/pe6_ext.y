%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex();
void yyerror(const char *s);

int tempCount = 1;
int labelCount = 1;

char *g_cond = NULL;  /* last parsed condition (set in C's action)       */
char *g_L1   = NULL;  /* L1 passed from if_marker via parent mid-action  */

char* newTemp() {
    char *t = malloc(10);
    sprintf(t, "t%d", tempCount++);
    return t;
}
char* newLabel() {
    char *l = malloc(10);
    sprintf(l, "L%d", labelCount++);
    return l;
}
void emit(char *op, char *a1, char *a2, char *res) {
    printf("(%s, %s, %s, %s)\n", op, a1, a2, res);
}
%}

%union { char *str; }

%token <str> ID
%token PLUS MINUS MUL DIV ASSIGN
%token LT GT LE GE EQ NE
%token IF ELSE DO WHILE
%token LPAREN RPAREN LBRACE RBRACE SEMI

%type <str> expr C rel
%type <str> if_marker then_marker do_marker

%%

program: S ;

/* Block: { S } or { } — collapses 4 if-else variants into 1 rule */
block: LBRACE S RBRACE | LBRACE RBRACE ;

/*
 * if_marker — fires after  IF ( C )
 * Uses g_cond (set by C's action) to emit:  ifFalse C goto L1
 * Returns L1.
 */
if_marker:
    /* empty */ {
        $$ = newLabel();
        emit("ifFalse", g_cond, "-", $$);
    }
;

/*
 * then_marker — fires after the then-block closes.
 * Parent must set g_L1 = L1 in a mid-rule action before this fires.
 * Emits goto L2, prints L1:, returns L2.
 */
then_marker:
    /* empty */ {
        $$ = newLabel();
        emit("goto", "-", "-", $$);
        printf("%s:\n", g_L1);
    }
;

/*
 * do_marker — fires right after DO.
 * Prints L1: and returns L1.
 */
do_marker:
    /* empty */ {
        $$ = newLabel();
        printf("%s:\n", $$);
    }
;

S:
    /* x = expr ; */
      ID ASSIGN expr SEMI {
          emit("=", $3, "-", $1);
      }

    /*
     * if ( C ) block if_marker block then_marker ELSE block
     *
     *  $1=IF $2=( $3=C $4=) $5=if_marker $6=block $7={g_L1=$5} $8=then_marker $9=ELSE $10=block
     *
     * Emit order (all ICG is printed in parse order):
     *   ifFalse C goto L1    <- if_marker
     *   <then-block code>
     *   goto L2              <- then_marker
     *   L1:                  <- then_marker
     *   <else-block code>
     *   L2:                  <- final action
     */
    | IF LPAREN C RPAREN if_marker block { g_L1 = $5; } then_marker ELSE block {
          printf("%s:\n", $8);
      }

    /*
     * do do_marker block while ( C ) ;
     *
     * Emit order:
     *   L1:           <- do_marker
     *   <body code>
     *   if C goto L1  <- final action
     */
    | DO do_marker block WHILE LPAREN C RPAREN SEMI {
          emit("if", $6, "-", $2);
      }
;

C:
      ID rel ID {
          char *t = malloc(50);
          sprintf(t, "%s %s %s", $1, $2, $3);
          $$ = t;
          g_cond = t;
      }
;

rel:
      LT  { $$ = "<"; }  | GT  { $$ = ">"; }
    | LE  { $$ = "<="; } | GE  { $$ = ">="; }
    | EQ  { $$ = "=="; } | NE  { $$ = "!="; }
;

expr:
      expr PLUS expr { char *t = newTemp(); emit("+", $1, $3, t); $$ = t; }
    | expr MUL  expr { char *t = newTemp(); emit("*", $1, $3, t); $$ = t; }
    | ID         { $$ = $1; }
;

%%

void yyerror(const char *s) { printf("Error: %s\n", s); }

int main() {
    printf("Enter code:\n");
    yyparse();
    return 0;
}
