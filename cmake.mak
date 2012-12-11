#cmake-2.8.10.2.tar.gz

cmake.version := 2.8.10.2
cmake.dir := cmake-$(cmake.version)
cmake.tgz := $(cmake.dir).tar.gz

.cmake.args := \
	--prefix=$(pfx)

.cmake.unpack: $(cmake.tgz)
	tar xvf $^ && touch $(CWD)/$@
	
.cmake.config: .cmake.unpack
	cd $(cmake.dir) && \
	sh configure $(.cmake.args)  && \
	touch $(CWD)/$@

.cmake.make: .cmake.config
	cd $(cmake.dir) && \
	$(MAKE) && \
	touch $(CWD)/$@

.cmake.install: .cmake.make
	cd $(cmake.dir) && \
	make install $(DEST) && \
	touch $(CWD)/$@

.cmake.clean:
	rm -rf $(cmake.dir) .cmake.*
