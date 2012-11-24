#include openssl.mak

curl.version := 7.28.1
curl.dir := curl-$(curl.version)
curl.tgz := $(curl.dir).tar.bz2

.curl.args := \
	--prefix=$(pfx) \
	--with-ssl=$(CWD)/install

.curl.unpack: $(curl.tgz)
	tar xvf $^ && touch $(CWD)/$@

.curl.config: .curl.unpack .ssl.install
	cd $(curl.dir) && \
	CFLAGS="$(CFLAGS)" CXXFLAGS="$(CFLAGS)" sh configure $(.curl.args)  && \
	touch $(CWD)/$@

.curl.make: .curl.config
	cd $(curl.dir) && \
	$(MAKE) -j4 && \
	touch $(CWD)/$@

.curl.install: .curl.make
	cd $(curl.dir) && \
	make install $(DEST) && \
	touch $(CWD)/$@

.curl.clean:
	rm -rf $(curl.dir) .curl.*
