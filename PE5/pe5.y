%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex();
void yyerror(const char *s);

/* AST Node */
struct Node {
    char val[20];
    struct Node *left, *right;
};

/* Create node */
struct Node* newNode(char *val, struct Node *l, struct Node *r) {
    struct Node *node = (struct Node*)malloc(sizeof(struct Node));
    strcpy(node->val, val);
    node->left = l;
    node->right = r;
    return node;
}

/*
 * printTree - draws the AST using plain ASCII characters.
 * Works on Windows CMD, PowerShell, Linux, Mac.
 *
 * Example for a + b * c :
 *
 *         .-- [c]
 *     .-- [*]
 *         `-- [b]
 * [+]
 *     `-- [a]
 *
 * Right subtree printed above, left subtree below.
 * prefix : connector string from ancestors
 * isLeft : 1 = left child, 0 = right child
 */
void printTree(struct Node *root, const char *prefix, int isLeft) {
    if (root == NULL) return;

    /* right child first (appears above current node) */
    if (root->right) {
        char newPrefix[512];
        snprintf(newPrefix, sizeof(newPrefix), "%s%s",
                 prefix,
                 isLeft ? "|       " : "        ");
        printTree(root->right, newPrefix, 0);
    }

    /* print current node */
    printf("%s%s[%s]\n", prefix, isLeft ? "`-- " : ".-- ", root->val);

    /* left child (appears below current node) */
    if (root->left) {
        char newPrefix[512];
        snprintf(newPrefix, sizeof(newPrefix), "%s%s",
                 prefix,
                 isLeft ? "        " : "|       ");
        printTree(root->left, newPrefix, 1);
    }
}

/* Print root node with its subtrees */
void printTreeRoot(struct Node *root) {
    if (root == NULL) return;
    if (root->right) printTree(root->right, "        ", 0);
    printf("[%s]\n", root->val);
    if (root->left)  printTree(root->left,  "        ", 1);
}

/* Postorder: Left -> Right -> Root  (= Reverse Polish Notation) */
void postorder(struct Node *root) {
    if (root == NULL) return;
    postorder(root->left);
    postorder(root->right);
    printf("%s ", root->val);
}

/* Inorder: Left -> Root -> Right */
void inorder(struct Node *root) {
    if (root == NULL) return;
    inorder(root->left);
    printf("%s ", root->val);
    inorder(root->right);
}

/* Preorder: Root -> Left -> Right */
void preorder(struct Node *root) {
    if (root == NULL) return;
    printf("%s ", root->val);
    preorder(root->left);
    preorder(root->right);
}
%}

%union {
    char *str;
    struct Node *node;
}

%token <str> ID NUM
%token PLUS MINUS MUL DIV LPAREN RPAREN

%type <node> expr

%left PLUS MINUS
%left MUL DIV

%%

input:
      expr {
          printf("\n+------------------------------+\n");
          printf("|  Abstract Syntax Tree (AST)  |\n");
          printf("+------------------------------+\n\n");

          printTreeRoot($1);

          printf("\n------------------------------\n");
          printf("Preorder  (Root->Left->Right) : ");
          preorder($1);

          printf("\nInorder   (Left->Root->Right) : ");
          inorder($1);

          printf("\nPostorder (Left->Right->Root) : ");
          postorder($1);

          printf("\n------------------------------\n");
          printf("* Postorder = Reverse Polish  : ");
          postorder($1);
          printf("\n------------------------------\n\n");
      }
    ;

expr:
      expr PLUS  expr      { $$ = newNode("+", $1, $3); }
    | expr MINUS expr      { $$ = newNode("-", $1, $3); }
    | expr MUL   expr      { $$ = newNode("*", $1, $3); }
    | expr DIV   expr      { $$ = newNode("/", $1, $3); }
    | LPAREN expr RPAREN   { $$ = $2; }
    | ID                   { $$ = newNode($1, NULL, NULL); }
    | NUM                  { $$ = newNode($1, NULL, NULL); }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
    fflush(stderr);
}

int main() {
    printf("Enter expression: ");
    fflush(stdout);
    yyparse();
    return 0;
}
