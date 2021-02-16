TARGET     = spi-nand-prog
PKG        = $(TARGET)

CC        ?= gcc
STRIP     ?= strip
INSTALL   ?= install
PREFIX    ?= /usr
BINDIR    ?= $(PREFIX)/bin
CFLAGS    ?= -std=gnu99 -Wall -O2
LDFLAGS   ?= -pthread

SRCS = core.c flashops.c gigadevice.c macronix.c main.c micron.c paragon.c spi-mem-drvs.c spi-mem-fx2qspi.c spi-mem-serprog.c spi-mem.c toshiba.c winbond.c

ifdef LIBS_BASE
CFLAGS += -I$(LIBS_BASE)/include
LDFLAGS += -L$(LIBS_BASE)/lib -Wl,-rpath -Wl,$(LIBS_BASE)/lib
endif

ifeq ($(CONFIG_STATIC), yes)
LDFLAGS += -static
endif

$(PKG): $(TARGET)

$(TARGET): $(SRCS)
	$(CC) $(CFLAGS) $(SRCS) $(LDFLAGS) -lusb-1.0 -o $@

clean: 
	rm -f $(TARGET)

strip: $(TARGET)
	$(STRIP) $(TARGET)

install: $(TARGET)
	mkdir -p $(DESTDIR)$(BINDIR)
	mkdir -p $(DESTDIR)/etc/udev/rules.d
	$(INSTALL) -m 0755 $(TARGET) $(DESTDIR)$(BINDIR)
	$(INSTALL) -m 0664 40-persistent-serprog.rules $(DESTDIR)/etc/udev/rules.d/40-persistent-serprog.rules

install-udev-rule:
	cp 40-persistent-serprog.rules /etc/udev/rules.d/
	udevadm control --reload-rules
.PHONY: clean install-udev-rule

debian/changelog:
	dch --create -v 1.0-1 --package $(PKG)

deb:
	dpkg-buildpackage -b -us -uc
.PHONY: install debian/changelog deb
