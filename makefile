# target ... : prerequisites ...
# 			command to generate target
# 

CC = i386-elf-g++

# 1. create a all-zero file with blocksize=512 and 1440KB
# 2. write boot.bin into the file skip 0 (seek attribute) blocks
# you need to install i386-elf-g++ by
#		brew install --debug i386-elf-gcc
myos.img : kernel.bin
	dd if=/dev/zero of=myos.img bs=512 count=2880 &&\
	dd if=kernel.bin of=myos.img seek=0 conv=notrunc

loader.o : loader.asm
	nasm -f elf32 loader.asm -o loader.o

func.o 	: func.asm
	nasm -f elf32 func.asm -o func.o

kernel.bin : loader.o func.o kmain.cpp font8x16.hpp mylowlevelfunc.hpp mystdio.hpp
	$(CC) -m32 kmain.cpp loader.o func.o font8x16.hpp mylowlevelfunc.hpp mystdio.hpp\
		-o kernel.bin \
		-nostdlib -ffreestanding -std=c++11 -mno-red-zone -fno-exceptions -nostdlib -fno-rtti -Wall -Wextra -Werror \
		-T linker.ld

kmain.o : kmain.cpp
	g++ kmain.cpp -o kmain.o

run : myos.img
	qemu-system-x86_64 -fda myos.img -vga std

.PHONY : clean # .PHONY means clean is not a file or an object
clean: 
	rm *.bin *.img *.o
