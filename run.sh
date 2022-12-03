nasm -f elf -g $1.s -o main.o &&
ld -m elf_i386 -o main main.o &&
chmod +x main &&
if [[ $2 = "st" ]]
then
    strace ./main
else
    ./main
fi