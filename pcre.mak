pcre.version := 8.31
pcre.dir := pcre-$(pcre.version)
pcre.tgz := $(pcre.dir).tar.gz
pcre.url:= ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/$(pcre.tgz)

$(pcre.tgz):
	wget $(pcre.url)

.pcre.args := \
	--prefix=$(pfx)

.pcre.unpack: $(pcre.tgz) pcre.sha1
	sha1sum -c pcre.sha1
	tar xvf $< && touch $(CWD)/$@

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
GLOBAL_CLEAN += .pcre.clean
