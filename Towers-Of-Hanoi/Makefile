.PHONY: clean all

AS = gcc
ARM = arm
ASFLAGS = -g

PROG = towers
OBJS = towers.o
ASMS = towers.s

all: $(PROG)

$(PROG): $(ASMS)
	$(AS) $(ASFLAGS) -o $(PROG) $(ASMS)

clean:
	-rm -f $(OBJS) *.~
