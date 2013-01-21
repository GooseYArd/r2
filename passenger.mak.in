INSTALL := $(CWD)/install

.passenger.patch: .gems.install
	for i in $(CWD)/passenger-*.patch; do patch -p0 < $$i; done
	touch $@

.passenger.install: .passenger.patch .gems.install .nginx.unpack .curl.install .openssl.install .zlib.install .pcre.install        
	export PATH=$(INSTALL)/bin:$(PATH) && \
	export CFLAGS="$(CFLAGS) $(LDFLAGS)" && \
	export CXXFLAGS="$(CXXFLAGS)" && \
	export LDFLAGS="$(LDFLAGS)" && \
	install/bin/passenger-install-nginx-module --extra-configure-flags="--with-openssl=$(CWD)/$(openssl.dir) --with-zlib=$(CWD)/$(zlib.dir) --with-pcre=$(CWD)/$(pcre.dir)" --auto --prefix=$(pfx) --nginx-source-dir=$(CWD)/$(nginx.dir) 
	touch $@

.passenger.clean:
	rm -f .passenger.*
GLOBAL_CLEAN += .passenger.clean
