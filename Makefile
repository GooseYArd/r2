CWD = $(PWD)
pfx := $(CWD)/install
DEST :=

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

bootstrap: $(CXX) $(NCURSESH)

%.sh: config.m4 %.sh.in
	m4 $^ > $@
	chmod +x $@

foo:
	echo $(GLOBAL_CLEAN)

clean: $(GLOBAL_CLEAN)
	rm -rf install pgstart.sh pgstop.sh pginit.sh
