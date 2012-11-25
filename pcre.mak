pcre.version := 8.31
pcre.dir := pcre-$(pcre.version)
pcre.tgz := $(pcre.dir).tar.gz

.pcre.args := \
	--prefix=$(pfx)

.pcre.unpack: $(pcre.tgz)
	tar xvf $^ && touch $(CWD)/$@

.pcre.config: .pcre.unpack
	cd $(pcre.dir) && \
	CFLAGS="$(CFLAGS)" CXXFLAGS="$(CFLAGS)" sh configure $(.pcre.args)  && \
	touch $(CWD)/$@

.pcre.make: .pcre.config
	cd $(pcre.dir) && \
	$(MAKE) -j4 && \
	touch $(CWD)/$@

.pcre.install: .pcre.make
	cd $(pcre.dir) && \
	make install $(DEST) && \
	touch $(CWD)/$@

.pcre.clean:
	rm -rf $(pcre.dir) .pcre.*
