curl.version := 7.28.1
curl.dir := curl-$(curl.version)
curl.tgz := $(curl.dir).tar.bz2
curl.url := http://curl.haxx.se/download/$(curl.tgz)

$(curl.tgz): curl.sha1
	wget $(curl.url)
	sha1sum -c $<

.curl.args := \
	--prefix=$(pfx) \
	--with-ssl=$(CWD)/install

.curl.unpack: $(curl.tgz)
	tar xvf $^ && touch $(CWD)/$@
	

.curl.config: .curl.unpack .openssl.install
	cd $(curl.dir) && \
	CFLAGS="$(CFLAGS) -DOPENSSL_NO_SSL2" CXXFLAGS="$(CFLAGS) -DOPENSSL_NO_SSL2" sh configure $(.curl.args)  && \
	sed -i -e s/HAVE_SSLV2_CLIENT_METHOD\ 1/HAVE_SSLV2_CLIENT_METHOD\ 0/ lib/curl_config.h && \
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
GLOBAL_CLEAN += .curl.clean

.curl.distclean:
	rm -f $(curl.tgz)

GLOBAL_DISTCLEAN += .curl.distclean