
tictactoe.o: tictactoe.asm
	nasm -f elf64 -o tictactoe.o tictactoe.asm
tictactoe.x86_64: tictactoe.o
	ld -o tictactoe.x86_64 tictactoe.o -I/lib64/ld-linux-x86-64.so.2
run: tictactoe.x86_64
	./tictactoe.x86_64


