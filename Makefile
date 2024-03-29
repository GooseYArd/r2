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
	$(pfx)/bin/gem install bundler -v 1.3.1
	$(pfx)/bin/bundle config build.pg --with-pg-config=$(pfx)/bin/pg_config
	touch $@

.rack.install: .bundler.install
	$(pfx)/bin/gem install rack -v 1.5.2
	touch $@

.rails.install: .bundler.install
	$(pfx)/bin/gem install rails -v 3.2.12
	touch $@

.parseconfig.install: .bundler.install
	$(pfx)/bin/gem install parseconfig -v 1.0.2
	touch $@

.pg.install: .postgresql.install
	$(pfx)/bin/gem install pg -v 0.14.1

.netssh.install: 
	$(pfx)/bin/gem install net-ssh -v 2.6.6

$(CXX):
	sudo aptitude install g++

NCURSESH := /usr/include/ncurses.h
$(NCURSESH):
	sudo aptitude install libncurses5-dev

READLINEH := /usr/include/readline/readline.h
$(READLINEH):
	sudo aptitude install libreadline-dev libreadline6-dev

PAM_APPLH := /usr/include/security/pam_appl.h
$(PAM_APPLH):
	sudo aptitude install libpam0g-dev

EVENTH := /usr/include/event.h
$(EVENTH):
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
