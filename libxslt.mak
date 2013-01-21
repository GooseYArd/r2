libxslt.version := 1.1.28
libxslt.dir := libxslt-$(libxslt.version)
libxslt.tgz := $(libxslt.dir).tar.gz
libxslt.url := ftp://xmlsoft.org/libxml2/$(libxslt.tgz)

$(libxslt.tgz): libxslt.sha1
	wget $(libxslt.url)
	sha1sum -c $<

.libxslt.args := \
	--prefix=$(pfx) \
	--without-python \
	--with-libxml-prefix=$(pfx)	

.libxslt.unpack: $(libxslt.tgz)
	tar xvf $^ && touch $(CWD)/$@

.libxslt.config: .libxslt.unpack .libxml2.install
	cd $(libxslt.dir) && \
	CFLAGS="$(CFLAGS)" CXXFLAGS="$(CFLAGS)" sh configure $(.libxslt.args)  && \
	touch $(CWD)/$@

.libxslt.make: .libxslt.config
	cd $(libxslt.dir) && \
	$(MAKE) -j4 && \
	touch $(CWD)/$@

.libxslt.install: .libxslt.make
	cd $(libxslt.dir) && \
	make install $(DEST) && \
	touch $(CWD)/$@

.libxslt.clean:
	rm -rf $(libxslt.dir) .libxslt.*
GLOBAL_CLEAN += .libxslt.clean

.libxslt.distclean:
	rm -f $(libxslt.tgz)
GLOBAL_DISTCLEAN += .libxslt.distclean