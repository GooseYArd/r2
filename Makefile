CWD = $(PWD)
pfx := $(CWD)/install
DEST :=

include *.mak

CFLAGS := -I$(pfx)/include
CXXFLAGS := -I$(pfx)/include
LDFLAGS := -L$(pfx)/lib

all: \
	.percona.install \
	.ruby.install \
	.gems.install \
	.passenger.install

%.sh: config.m4 %.sh.in
	m4 $^ > $@
	chmod +x $@

<<<<<<< HEAD
clean: .percona.clean .bison.clean .cmake.clean .libaio.clean .mysql.clean .ruby.clean .yaml.clean .gems.clean .passenger.clean .nginx.clean .curl.clean .openssl.clean .zlib.clean .pcre.clean
=======
clean: .cmake.clean .libaio.clean .mysql.clean .ruby.clean .yaml.clean .gems.clean .passenger.clean .nginx.clean .curl.clean .openssl.clean .ncurses.clean .readline.clean .zlib.clean .pcre.clean
>>>>>>> ecae41debd7e6518b4c447cc184c98564f0d5074
	rm -rf install pgstart.sh pgstop.sh pginit.sh
