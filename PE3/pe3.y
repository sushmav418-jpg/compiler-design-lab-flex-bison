%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX 200

typedef struct {
    char name[64];
    char kind[20];
    char type[64];
    char storage[20];
    int  size;
    int  scope;
    int  line;
    int  hasInit;
    long initVal;
} Symbol;

Symbol table[MAX];
int    symCount = 0;
int    curScope = 0;

char curType[64]    = "int";
char curStorage[20] = "auto";

extern int  yylineno;
int yylex(void);
void yyerror(const char *s);

int getSize(const char *t) {
    if (strcmp(t,"char")==0)   return 1;
    if (strcmp(t,"short")==0)  return 2;
    if (strcmp(t,"int")==0)    return 4;
    if (strcmp(t,"float")==0)  return 8;
    if (strcmp(t,"double")==0) return 8;
    if (strcmp(t,"long")==0)   return 8;
    return 0;
}

void addSymbol(const char *name, const char *type, const char *kind,
               const char *storage, int line, int hasInit, long initV) {
    for (int i=0;i<symCount;i++)
        if (strcmp(table[i].name,name)==0 && table[i].scope==curScope) return;
    Symbol *s = &table[symCount++];
    strncpy(s->name,    name,    63); s->name[63]=0;
    strncpy(s->type,    type,    63); s->type[63]=0;
    strncpy(s->kind,    kind,    19); s->kind[19]=0;
    strncpy(s->storage, storage, 19); s->storage[19]=0;
    s->size    = getSize(type);
    s->scope   = curScope;
    s->line    = line;
    s->hasInit = hasInit;
    s->initVal = initV;
}

void printTable(void) {
    printf("\n+===========+==========+==========+==========+======+=======+======+================+\n");
    printf(  "|                                   SYMBOL  TABLE                                   |\n");
    printf(  "+===========+==========+==========+==========+======+=======+======+================+\n");
    printf(  "| %-9s | %-8s | %-8s | %-8s | %-4s | %-5s | %-4s | %-14s |\n",
             "Name","Kind","Type","Storage","Size","Scope","Line","Initializer");
    printf(  "+-----------+----------+----------+----------+------+-------+------+----------------+\n");
    for (int i=0;i<symCount;i++){
        char ibuf[20]="null";
        if (table[i].hasInit) snprintf(ibuf,20,"%ld",table[i].initVal);
        printf("| %-9s | %-8s | %-8s | %-8s | %-4d | %-5d | %-4d | %-14s |\n",
               table[i].name, table[i].kind, table[i].type,
               table[i].storage, table[i].size,
               table[i].scope, table[i].line, ibuf);
    }
    printf("+===========+==========+==========+==========+======+=======+======+================+\n");
}
%}

%union {
    char sval[64];
    long ival;
}

%token <sval> IDENTIFIER
%token <ival> INT_LITERAL
%token TINT TFLOAT TCHAR TDOUBLE TSHORT TLONG
%token TSTATIC TEXTERN TAUTO TREGISTER
%token TVOID TRETURN TIF TELSE TWHILE TFOR
%token SEMI LBRACE RBRACE LPAREN RPAREN COMMA ASSIGN
%token PLUS MINUS STAR SLASH PERCENT
%token EQ NEQ LT GT LE GE AND OR NOT

%type <sval> type_spec storage_spec
%type <ival> expr

%%

program
    : /* empty */
    | program external_decl
    ;

external_decl
    : decl_stmt
    | function_def
    ;

storage_spec
    : TSTATIC   { strcpy($$,"static");   }
    | TEXTERN   { strcpy($$,"extern");   }
    | TAUTO     { strcpy($$,"auto");     }
    | TREGISTER { strcpy($$,"register"); }
    ;

type_spec
    : TINT    { strcpy($$,"int");    strcpy(curType,"int");    }
    | TFLOAT  { strcpy($$,"float");  strcpy(curType,"float");  }
    | TCHAR   { strcpy($$,"char");   strcpy(curType,"char");   }
    | TDOUBLE { strcpy($$,"double"); strcpy(curType,"double"); }
    | TSHORT  { strcpy($$,"short");  strcpy(curType,"short");  }
    | TLONG   { strcpy($$,"long");   strcpy(curType,"long");   }
    ;

decl_stmt
    : type_spec decl_list SEMI
    | storage_spec type_spec { strcpy(curStorage,$1); } decl_list SEMI { strcpy(curStorage,"auto"); }
    ;

decl_list
    : decl_item
    | decl_list COMMA decl_item
    ;

decl_item
    : IDENTIFIER {
        addSymbol($1, curType, "variable", curStorage, yylineno, 0, 0);
    }
    | IDENTIFIER ASSIGN expr {
        addSymbol($1, curType, "variable", curStorage, yylineno, 1, $3);
    }
    ;

function_def
    : type_spec IDENTIFIER LPAREN {
        addSymbol($2, curType, "function", "extern", yylineno, 0, 0);
        curScope++;
    } param_list RPAREN compound_stmt {
        curScope--;
        strcpy(curStorage,"auto");
    }
    ;

param_list
    : /* empty */
    | param_item
    | param_list COMMA param_item
    ;

param_item
    : type_spec IDENTIFIER {
        addSymbol($2, $1, "parameter", "auto", yylineno, 0, 0);
    }
    ;

compound_stmt
    : LBRACE { curScope++; } stmt_list RBRACE { curScope--; }
    ;

stmt_list
    : /* empty */
    | stmt_list stmt
    ;

stmt
    : decl_stmt
    | expr SEMI
    | compound_stmt
    | TRETURN expr SEMI
    | TIF LPAREN expr RPAREN stmt
    | TIF LPAREN expr RPAREN stmt TELSE stmt
    | TWHILE LPAREN expr RPAREN stmt
    | TFOR LPAREN expr SEMI expr SEMI expr RPAREN stmt
    | SEMI
    ;

expr
    : INT_LITERAL               { $$ = $1; }
    | IDENTIFIER                { $$ = 0;  }
    | expr ASSIGN expr          { $$ = $3; }
    | expr PLUS  expr           { $$ = $1+$3; }
    | expr MINUS expr           { $$ = $1-$3; }
    | expr STAR  expr           { $$ = $1*$3; }
    | expr SLASH expr           { $$ = ($3)?$1/$3:0; }
    | LPAREN expr RPAREN        { $$ = $2; }
    | IDENTIFIER LPAREN RPAREN  { $$ = 0; }
    ;

%%

void yyerror(const char *s){
    fprintf(stderr,"Parse error at line %d: %s\n",yylineno,s);
}
int main(void){
    yyparse();
    printTable();
    return 0;
}
