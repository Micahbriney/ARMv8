.PHONY: clean all

AS = gcc
ARM = arm
ASMFLAGS =

PROG = haiku
OBJS = haiku.o
ASMS = haiku.s

all: $(PROG)

$(PROG): $(ASMS)
	$(AS) $(ASFLAGS) -o $(PROG) $(ASMS)

clean:
	-rm -f $(OBJS) *.~
