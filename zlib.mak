zlib.version := 1.2.7
zlib.dir := zlib-$(zlib.version)
zlib.tgz := $(zlib.dir).tar.gz
zlib.url := http://zlib.net/$(zlib.tgz)

$(zlib.tgz):
	wget $(zlib.url)

.zlib.args := \
	--prefix=$(pfx)

.zlib.unpack: $(zlib.tgz) zlib.sha1
	sha1sum -c zlib.sha1
	tar xvf $< && touch $(CWD)/$@

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
GLOBAL_CLEAN += .zlib.clean

.zlib.distclean:
	rm -f $(zlib.tgz)
	
GLOBAL_DISTCLEAN += .zlib.distclean