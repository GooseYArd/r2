readline.version := 6.2
readline.dir := readline-$(readline.version)
readline.tgz := $(readline.dir).tar.gz

.readline.args := \
	--prefix=$(pfx)

.readline.unpack: $(readline.tgz)
	tar xvf $^ && touch $(CWD)/$@

.readline.config: .readline.unpack .openssl.install .ncurses.install
	cd $(readline.dir) && \
	CFLAGS="$(CFLAGS)" CXXFLAGS="$(CFLAGS)" sh configure $(.readline.args)  && \
	touch $(CWD)/$@

.readline.make: .readline.config
	cd $(readline.dir) && \
	$(MAKE) -j4 && \
	touch $(CWD)/$@

.readline.install: .readline.make
	cd $(readline.dir) && \
	make install $(DEST) && \
	touch $(CWD)/$@

.readline.clean:
	rm -rf $(readline.dir) .readline.*
