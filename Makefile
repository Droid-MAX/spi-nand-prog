TARGET     = spi-nand-prog

CC        ?= gcc
STRIP     ?= strip
INSTALL   ?= install
PREFIX    ?= /usr
BINDIR    ?= $(PREFIX)/bin
CFLAGS    ?= -std=gnu99 -Wall -O2 -D_FILE_OFFSET_BITS=64 -I$(shell pwd)/include
LDFLAGS   ?= -pthread

SRCS = $(wildcard spi-mem/*.c spi-mem/ch347/*.c spi-nand/*.c) flashops.c main.c

ifdef LIBS_BASE
CFLAGS += -I$(LIBS_BASE)/include
LDFLAGS += -L$(LIBS_BASE)/lib -Wl,-rpath -Wl,$(LIBS_BASE)/lib
endif

ifeq ($(CONFIG_STATIC), yes)
LDFLAGS += -static
endif

ifeq ($(TARGET_OS), MinGW)
EXEC_SUFFIX := .exe
SRCS += $(RES)
CFLAGS += -posix
CFLAGS += -Dffs=__builtin_ffs
CFLAGS += -D__USE_MINGW_ANSI_STDIO=1
endif

ifeq ($(TARGET_OS), Darwin)
CFLAGS += -Wno-gnu-designator
LDFLAGS += -lobjc -Wl,-framework,IOKit -Wl,-framework,CoreFoundation -Wl,-framework,Security
endif

$(TARGET)$(EXEC_SUFFIX): $(SRCS)
	$(CC) $(CFLAGS) $(SRCS) $(LDFLAGS) -lusb-1.0 -o $@

clean: 
	rm -f $(TARGET)$(EXEC_SUFFIX)

strip: $(TARGET)$(EXEC_SUFFIX)
	$(STRIP) $(TARGET)$(EXEC_SUFFIX)

install: $(TARGET)
	mkdir -p $(DESTDIR)$(BINDIR)
	mkdir -p $(DESTDIR)/etc/udev/rules.d
	$(INSTALL) -m 0755 $(TARGET) $(DESTDIR)$(BINDIR)
	$(INSTALL) -m 0664 $(shell pwd)/udev/99-ch347.rules $(DESTDIR)/etc/udev/rules.d/99-ch347.rules

install-udev-rule:
	cp $(shell pwd)/udev/99-ch347.rules /etc/udev/rules.d/
	udevadm control --reload-rules
.PHONY: clean install-udev-rule
