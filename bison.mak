bison.version := 2.7
bison.dir := bison-$(bison.version)
bison.tgz := $(bison.dir).tar.gz

.bison.args := \
	--prefix=$(pfx) \
	--with-shared \
	--enable-rpath

.bison.unpack: $(bison.tgz)
	tar xvf $^ && touch $(CWD)/$@

.bison.config: .bison.unpack
	cd $(bison.dir) && \
	CFLAGS="$(CFLAGS)" CXXFLAGS="$(CFLAGS)" sh configure $(.bison.args)  && \
	touch $(CWD)/$@

.bison.make: .bison.config
	cd $(bison.dir) && \
	$(MAKE) -j4 && \
	touch $(CWD)/$@

.bison.install: .bison.make
	cd $(bison.dir) && \
	make install $(DEST) && \
	touch $(CWD)/$@

.bison.clean:
	rm -rf $(bison.dir) .bison.*

GLOBAL_CLEAN += .bison.clean
