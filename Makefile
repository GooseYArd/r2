CWD = $(PWD)
pfx := $(CWD)/install
DEST :=

%.mak: %.mak.in r2.m4
	m4 $< > $@

SUBMAKES := $(wildcard submakes/*.mak.in)

include $(SUBMAKES:mak.in=mak)

CFLAGS := -I$(pfx)/include
CXXFLAGS := -I$(pfx)/include
LDFLAGS := -L$(pfx)/lib

CXX := /usr/bin/g++

%/.exist:
	mkdir -p $(@D)
	touch $@

all: \
	dists/.exist \
	build/.exist \
	.ruby.install \
	.passenger.install \
	.node.install \
	.sqlite.install \
	.rails.install

# Misc small targetrs
.bundler.install: .ruby.install
	$(pfx)/bin/gem install bundler -v 1.2.3
	$(pfx)/bin/bundle config build.pg --with-pg-config=$(pfx)/bin/pg_config
	touch $@

.rack.install: .bundler.install
	$(pfx)/bin/gem install rack -v 1.4.4
	touch $@

.rails.install: .bundler.install
	$(pfx)/bin/gem install rails -v 3.2.11
	touch $@

.parseconfig.install: .bundler.install
	$(pfx)/bin/gem install parseconfig -v 1.0.2
	$(pfx)/bin/gem install pg -v 0.14.1
	$(pfx)/bin/gem install net-ssh -v 2.6.3

	touch $@

$(CXX):
	sudo aptitude install g++

$(NCURSESH): /usr/include/ncurses.h
	sudo aptitude install libncurses5-dev

$(READLINEH): /usr/include/readline/readline.h
	sudo aptitude install libreadline-dev libreadline6-dev

$(PAM_APPLH): /usr/include/security/pam_appl.h
	sudo aptitude install libpam0g-dev

$(EVENTH): /usr/include/event.h
	sudo aptitude install libevent-dev

bootstrap: $(CXX) $(NCURSESH) $(READLINEH) $(PAM_APPLH) $(EVENTH)

%.sh: config.m4 %.sh.in
	m4 $^ > $@
	chmod +x $@

foo:
	echo $(GLOBAL_CLEAN)

clean: $(GLOBAL_CLEAN)
	rm -rf install pgstart.sh pgstop.sh pginit.sh

distclean: clean $(GLOBAL_DISTCLEAN)
