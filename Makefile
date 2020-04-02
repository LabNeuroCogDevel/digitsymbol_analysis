all: txt/all_long.txt

txt/taskfiles.ls:
	@mkls $@ '../DigitSymbol-20*-1*.txt'

txt/all_long.txt: ./00_get.bash txt/taskfiles.ls
	./00_get.bash
