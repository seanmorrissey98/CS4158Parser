#!/bin/bash
flex project.l && gcc -o Lexer lex.yy.c && ./Lexer