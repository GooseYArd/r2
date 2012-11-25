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

install/data/postgresql.conf: postgresql.conf.master.in
	$(pfx)/bin/initdb -D $(CWD)/install/data --locale=en_US.UTF-8 --lc-messages=sv_SE.UTF-8
	m4 $< > $@
	$(pfx)/bin/postgres -D ROOT/install/data >logfile 2>&1 &
	echo Waiting for database to come up
	sleep 10
	$(pfx)/bin/createuser --login --superuser --replication repmgr
	$(pfx)/bin/createdb pgbench
	$(pfx)/bin/pgbench -i -s 10 pgbench

%/pg_hba.conf: pg_hba.conf.%.in
	m4 $< > $@

db.test: install/data/postgresql.conf pgstart.sh pginit.sh pgstop.sh
	touch db.test

.db.clean: 
	rm -rf install/data

clean: .pg.clean .ruby.clean .yaml.clean .gems.clean .passenger.clean .repmgr.clean .nginx.clean .curl.clean .openssl.clean .ncurses.clean .readline.clean .zlib.clean
	rm -rf install pgstart.sh pgstop.sh pginit.sh
