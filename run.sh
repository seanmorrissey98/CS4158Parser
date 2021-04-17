#!/bin/bash
flex project.l && bison -d project.y && gcc lex.yy.c project.tab.c -lm -o test.o && ./test.o