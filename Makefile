#
# upload-stuff Makefile
#

PREFIX ?= /usr/local

BIN_DIR ?= $(DESTDIR)$(PREFIX)/bin

USER ?= $(shell id -un)
GROUP ?= $(shell stat --format=%G $(DESTDIR)$(PREFIX) 2>/dev/null || id -gn)

all:

check:
	./upload-stuff.sh --help | grep -Fq 'Usage'
	./upload-stuff.sh --dry-run upload-stuff.sh | grep -Fq '⇢'

clean:
distclean: clean
maintainer-clean: distclean

install: all
	install -o $(USER) -g $(GROUP) -m 0755 upload-stuff.sh \
	 $(BIN_DIR)/upload-stuff
