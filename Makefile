CWD = $(PWD)
pfx := $(CWD)/install
DEST :=

GETURL := wget --no-use-server-timestamps

%.mak: %.mak.in r2.m4
	m4 $< > $@

include *.mak

CFLAGS := -I$(pfx)/include
CXXFLAGS := -I$(pfx)/include
LDFLAGS := -L$(pfx)/lib

CXX := /usr/bin/g++

all: \
	.percona.install \
	.ruby.install \
	.gems.install \
	.passenger.install \
	.node.install \
	.sqlite.install

$(CXX):
	sudo aptitude install g++

$(NCURSESH): /usr/include/ncurses.h
	sudo aptitude install libncurses5-dev

$(READLINEH): /usr/include/readline/readline.h
	sudo aptitude install libreadline-dev libreadline6-dev

bootstrap: $(CXX) $(NCURSESH) $(READLINEH)

%.sh: config.m4 %.sh.in
	m4 $^ > $@
	chmod +x $@

foo:
	echo $(GLOBAL_CLEAN)

clean: $(GLOBAL_CLEAN)
	rm -rf install pgstart.sh pgstop.sh pginit.sh

distclean: clean $(GLOBAL_DISTCLEAN)
