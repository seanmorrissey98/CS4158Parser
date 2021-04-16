#!/bin/bash
flex project.l && bison -d project.y && gcc lex.yy.c y.tab.c -lm -o test.o && ./test.o