ncurses.version := 5.9
ncurses.dir := ncurses-$(ncurses.version)
ncurses.tgz := $(ncurses.dir).tar.gz

.ncurses.args := \
	--prefix=$(pfx) \
	--with-shared \
	--enable-rpath

.ncurses.unpack: $(ncurses.tgz)
	tar xvf $^ && touch $(CWD)/$@

.ncurses.config: .ncurses.unpack .ssl.install
	cd $(ncurses.dir) && \
	CFLAGS="$(CFLAGS)" CXXFLAGS="$(CFLAGS)" sh configure $(.ncurses.args)  && \
	touch $(CWD)/$@

.ncurses.make: .ncurses.config
	cd $(ncurses.dir) && \
	$(MAKE) -j4 && \
	touch $(CWD)/$@

.ncurses.install: .ncurses.make
	cd $(ncurses.dir) && \
	make install $(DEST) && \
	touch $(CWD)/$@

.ncurses.clean:
	rm -rf $(ncurses.dir) .ncurses.*
