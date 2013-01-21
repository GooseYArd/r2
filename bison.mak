bison.version := 2.7
bison.dir := bison-$(bison.version)
bison.tgz := $(bison.dir).tar.gz
bison.url := ftp://ftp.gnu.org/pub/gnu/bison/$(bison.tgz)

$(bison.tgz):
	wget $(bison.url)

.bison.args := \
	--prefix=$(pfx) \
	--with-shared \
	--enable-rpath

.bison.unpack: $(bison.tgz) bison.sha1
	sha1sum -c bison.sha1
	tar xvf $< && touch $(CWD)/$@

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

.bison.distclean:
	rm -f $(bison.tgz)

GLOBAL_DISTCLEAN += .bison.distclean
