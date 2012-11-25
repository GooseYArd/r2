CWD = $(PWD)
pfx := $(CWD)/install
DEST :=

include *.mak

CFLAGS := -I$(pfx)/include
CXXFLAGS := -I$(pfx)/include
LDFLAGS := -L$(pfx)/lib

all: \
	.pg.install \
	.ruby.install \
	.gems.install \
	.repmgr.install \
	.passenger.install

%.sh: config.m4 %.sh.in
	m4 $^ > $@
	chmod +x $@

%/postgresql.conf: postgresql.conf.%.in
	m4 $< > $@

%/pg_hba.conf: pg_hba.conf.%.in
	m4 $< > $@

db.test: install/data/postgresql.conf install/data/pg_hba.conf
	touch db.test

.db.clean: 
	rm -rf install/data

clean: .pg.clean .ruby.clean .yaml.clean .gems.clean .passenger.clean .repmgr.clean .nginx.clean .curl.clean .openssl.clean .ncurses.clean .readline.clean .zlib.clean .pcre.clean
	rm -rf install pgstart.sh pgstop.sh pginit.sh
