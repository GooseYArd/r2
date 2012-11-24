nginx.version := 1.3.8
nginx.dir = nginx-$(nginx.version)
nginx.tgz := $(nginx.dir).tar.gz

.nginx.unpack: $(nginx.tgz)
	tar xvf $^ && touch $(CWD)/$@
.nginx.clean:
	rm -rf $(nginx.dir)
	rm -f .nginx.*
