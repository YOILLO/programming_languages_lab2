
program: build/main.o build/lib.o build/dict.o
	ld -o $@ $^

build:
	mkdir -p build

build/main.o: src/main.asm inc/lib.inc inc/word.inc inc/colon.inc Makefile | build
	nasm -f elf64 -o $@ src/main.asm

build/lib.o: src/lib.asm
	nasm -f elf64 -o $@ $^

build/dict.o: src/dict.asm
	nasm -f elf64 -o $@ $^

clean:
	rm -rf build program

