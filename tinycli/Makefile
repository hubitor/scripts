CC = gcc
#DEBUG_FLAGS= -g -DDEBUG
CFLAGS := $(CFLAGS) $(DEBUG_FLAGS) -std=gnu11 -Wall -O2 -pipe -march=native
OFILES =  build_in_cmd.o tinycli.o
PROG = tinycli

.PHONY: clean

$(PROG): $(OFILES)
	$(CC) $(LDFLAGS) -o $@ $^

minimal: $(OFILES) start.S
	$(CC) $(LDFLAGS) -nostartfiles -ffreestatnding -o $(PROG) $^
	strip $(PROG)

%.o: %.c %.h
	$(CC) $(CFLAGS) -c $^

clean:
	rm $(OFILES)
