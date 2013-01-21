openssl.version := 1.0.1c
openssl.dir := openssl-$(openssl.version)
openssl.tgz := $(openssl.dir).tar.gz
openssl.url := ftp://ftp.openssl.org/source/$(openssl.tgz)

$(openssl.tgz): openssl.sha1
	wget $(openssl.url)
	sha1sum -c $<

.openssl.args := \
	--prefix=$(pfx) --openssldir=$(pfx)/openssl shared

.openssl.unpack: $(openssl.tgz)
	tar xvf $^ && touch $(CWD)/$@

.openssl.config: .openssl.unpack .zlib.install
	cd $(openssl.dir) && \
	CFLAGS="$(CFLAGS)" CXXFLAGS="$(CFLAGS)" ./config $(.openssl.args)  && \
	touch $(CWD)/$@

.openssl.make: .openssl.config
	cd $(openssl.dir) && \
	sed 's# libcrypto.a##;s# libssl.a##' < Makefile > Makefile.tmp && \
	mv Makefile.tmp Makefile && \
	$(MAKE) && \
	touch $(CWD)/$@

.openssl.install: .openssl.make
	cd $(openssl.dir) && \
	make install $(DEST) && \
	touch $(CWD)/$@

.openssl.clean:
	rm -rf $(openssl.dir) .openssl.*
GLOBAL_CLEAN += .openssl.clean
