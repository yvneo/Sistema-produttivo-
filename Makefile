AS_FLAGS = --32 
DEBUG = -gstabs
LD_FLAGS = -m elf_i386

SRC_PATH = src

all: bin/out

bin/out: create_folders obj/algoritmo_edf.o obj/algoritmo_hpf.o obj/programmazione.o obj/itoa.o obj/main.o obj/read_file.o
	ld $(LD_FLAGS) obj/algoritmo_edf.o obj/algoritmo_hpf.o obj/programmazione.o obj/itoa.o obj/main.o obj/read_file.o -o bin/pianificatore
	
create_folders:
	mkdir -p obj
	mkdir -p bin

obj/algoritmo_edf.o: src/algoritmo_edf.s
	as $(AS_FLAGS) $(DEBUG) $(SRC_PATH)/algoritmo_edf.s -o obj/algoritmo_edf.o

obj/algoritmo_hpf.o: src/algoritmo_hpf.s
	as $(AS_FLAGS) $(DEBUG) $(SRC_PATH)/algoritmo_hpf.s -o obj/algoritmo_hpf.o

obj/itoa.o: src/itoa.s
	as $(AS_FLAGS) $(DEBUG) $(SRC_PATH)/itoa.s -o obj/itoa.o

obj/programmazione.o: src/programmazione.s
	as $(AS_FLAGS) $(DEBUG) $(SRC_PATH)/programmazione.s -o obj/programmazione.o

obj/main.o: src/main.s
	as $(AS_FLAGS) $(DEBUG) $(SRC_PATH)/main.s -o obj/main.o

obj/read_file.o: src/read_file.s
	as $(AS_FLAGS) $(DEBUG) $(SRC_PATH)/read_file.s -o obj/read_file.o

clean:
	rm -f obj/*.o bin/pianificatore
	rmdir obj bin
	