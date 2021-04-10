#ifndef EDLIS_H
#define EDLIS_H

#include "term.h"

static const float VERSION = 1.73;
#define ROW_SIZE 4000
#define COL_SIZE 255
#define COPY_SIZE 500


static const int NIL = 0;


void signal_handler(int signo);
void input(char* str);
void edit_screen(char *fname);
void display_command(char *fname);
void display_screen(void);
void display_line(int line);
void setcolor(int n);
void backspace(void);
void insertcol(void);
void insertrow(void);
int getch(void);
void deleterow(void);
int findeol(int row);
struct position findlparen(int bias);
struct position findrparen(int bias);
void reset_paren(void);
void restore_paren(void);
void emphasis_lparen(void);
void emphasis_rparen(void);
void softtabs(int n);
void save_data(char *name);
int is_special(int row, int col);
int findnext(int row, int col);
void remove_headspace(int row);
int calc_tabs(void);
void copy_selection(void);
void paste_selection(void);
void delete_selection(void);
int check_token(int row, int col);
char* get_fragment(void);
void find_candidate(void);
void replace_fragment(char* newstr);
struct position find_word(char* word);
void replace_word(char* str1, char* str2);

#endif
