nginx.version := 1.2.6
nginx.dir = nginx-$(nginx.version)
nginx.tgz := $(nginx.dir).tar.gz

.nginx.unpack: $(nginx.tgz)
	tar xvf $^ && touch $(CWD)/$@
.nginx.clean:
	rm -rf $(nginx.dir)
	rm -f .nginx.*
GLOBAL_CLEAN += .nginx.clean
