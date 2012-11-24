zlib.version := 1.2.7
zlib.dir := zlib-$(zlib.version)
zlib.tgz := $(zlib.dir).tar.gz

.zlib.args := \
	--prefix=$(pfx)

.zlib.unpack: $(zlib.tgz)
	tar xvf $^ && touch $(CWD)/$@

.zlib.config: .zlib.unpack
	cd $(zlib.dir) && \
	CFLAGS="$(CFLAGS)" CXXFLAGS="$(CFLAGS)" sh configure $(.zlib.args)  && \
	touch $(CWD)/$@

.zlib.make: .zlib.config
	cd $(zlib.dir) && \
	$(MAKE) && \
	touch $(CWD)/$@

.zlib.install: .zlib.make
	cd $(zlib.dir) && \
	make install $(DEST) && \
	touch $(CWD)/$@

.zlib.clean:
	rm -rf $(zlib.dir) .zlib.*
