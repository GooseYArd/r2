libxml2.version := 2.9.0
libxml2.dir := libxml2-$(libxml2.version)
libxml2.tgz := $(libxml2.dir).tar.gz

.libxml2.args := \
	--prefix=$(pfx)

.libxml2.unpack: $(libxml2.tgz)
	tar xvf $^ && touch $(CWD)/$@

.libxml2.config: .libxml2.unpack
	cd $(libxml2.dir) && \
	CFLAGS="$(CFLAGS)" CXXFLAGS="$(CFLAGS)" sh configure $(.libxml2.args)  && \
	touch $(CWD)/$@

.libxml2.make: .libxml2.config
	cd $(libxml2.dir) && \
	$(MAKE) -j4 && \
	touch $(CWD)/$@

.libxml2.install: .libxml2.make
	cd $(libxml2.dir) && \
	make install $(DEST) && \
	touch $(CWD)/$@

.libxml2.clean:
	rm -rf $(libxml2.dir) .libxml2.*
GLOBAL_CLEAN += .libxml2.clean
