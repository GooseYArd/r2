INSTALL := $(CWD)/install

.passenger.install: .gems.install .nginx.unpack
	install/bin/passenger-install-nginx-module --extra-configure-flags="--with-openssl=$(CWD)/$(openssl.dir) --with-zlib=$(CWD)/$(zlib.dir)" --auto --prefix=$(pfx) --nginx-source-dir=$(CWD)/$(nginx.dir) 
	touch $@

.passenger.clean:
	rm -f .passenger.*
