nginx.version := 1.2.6
nginx.dir = nginx-$(nginx.version)
nginx.tgz := $(nginx.dir).tar.gz
nginx.url :=  http://nginx.org/download/$(nginx.tgz)

$(nginx.tgz): 
	wget $(nginz.url)

.nginx.unpack: $(nginx.tgz) nginx.sha1
	sha1sum -c nginx.sha1
	tar xvf $< && touch $(CWD)/$@
.nginx.clean:
	rm -rf $(nginx.dir)
	rm -f .nginx.*
GLOBAL_CLEAN += .nginx.clean

.nginx.distclean:
	rm -f $(nginx.tgz)
GLOBAL_DISTCLEAN += .nginx.distclean
