#‘sqlite-autoconf-3071501.tar.gz’

sqlite.version := 3071502
sqlite.dir := sqlite-autoconf-$(sqlite.version)
sqlite.tgz := $(sqlite.dir).tar.gz
sqlite.url := http://www.sqlite.org/$(sqlite.tgz)

$(sqlite.tgz):
	wget $(sqlite.url)

.sqlite.args := \
	--prefix=$(pfx)

.sqlite.unpack: $(sqlite.tgz) sqlite.sha1
	sha1sum -c sqlite.sha1
	tar xvf $< && touch $(CWD)/$@

.sqlite.config: .sqlite.unpack
	cd $(sqlite.dir) && \
	CFLAGS="$(CFLAGS)" CXXFLAGS="$(CFLAGS)" sh configure $(.sqlite.args)  && \
	touch $(CWD)/$@

.sqlite.make: .sqlite.config
	cd $(sqlite.dir) && \
	$(MAKE) -j4 && \
	touch $(CWD)/$@

.sqlite.install: .sqlite.make
	cd $(sqlite.dir) && \
	make install $(DEST) && \
	touch $(CWD)/$@

.sqlite.clean:
	rm -rf $(sqlite.dir) .sqlite.*
GLOBAL_CLEAN += .sqlite.clean

.sqlite.distclean:
	rm -f $(sqlite.tgz)
GLOBAL_DISTCLEAN += .sqlite.distclean
