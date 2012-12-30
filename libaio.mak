#libaio_0.3.109.orig.tar.gz
libaio.version := 0.3.109
libaio.dir := libaio-$(libaio.version)
libaio.tgz := libaio_$(libaio.version).orig.tar.gz 

libaio.args :=

.libaio.unpack: $(libaio.tgz)
	tar xvf $^ && touch $(CWD)/$@

.libaio.config: .libaio.unpack
	cd $(libaio.dir) && \
	touch $(CWD)/$@

.libaio.make: .libaio.config
	cd $(libaio.dir) && \
	$(MAKE) -j4 && \
	touch $(CWD)/$@

.libaio.install: .libaio.make
	cd $(libaio.dir) && \
	make install prefix=$(pfx) && \
	touch $(CWD)/$@

.libaio.clean:
	rm -rf $(libaio.dir) .libaio.*
GLOBAL_CLEAN += .libaio.clean
