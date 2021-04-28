# CS4158: A Parser for JIBUC Programs
--------------
## Overview
This project was created to parse JIBUC Programs using Yacc and Bison. It was developed on Ubuntu Linux through WSL and used GNU's C compiler.

## How-to
The submission of this project included a **Shell file** called `run.sh`. This shell file was primarily used to run the parser.
To pass a file into be parsed, simply run the following command in the same directory as all of the files:
```
./run.sh < filename.txt
```
Where `filename` is replaced with the relevant program filename which you want to use.
_Please note that the files need to use unix quotes and unix new lines or else will raise parse errors_

Or to run the parser and pass in a language through the command line, simply run the following command in the same directory as all of the files:
```
./run.sh
```