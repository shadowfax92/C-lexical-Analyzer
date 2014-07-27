a.out: lex.yy.c
	gcc lex.yy.c -ll

lex.yy.c: scanner.l
	flex scanner.l

clean: 
	rm -f a.out lex.yy.c core
