
#cmake-2.8.10.2.tar.gz

cmake.majorver := 2.8
cmake.version := $(cmake.majorver).10.2
cmake.dir := cmake-$(cmake.version)
cmake.tgz := $(cmake.dir).tar.gz
cmake.url := http://www.cmake.org/files/v$(cmake.majorver)/$(cmake-version).tar.gz

$(cmake.tgz): cmake.sha1
	wget $(cmake.url)
	sha1sum -c $<

.cmake.args := \
	--prefix=$(pfx)

.cmake.unpack: $(cmake.tgz)
	tar xvf $^ && touch $(CWD)/$@
	
.cmake.config: .cmake.unpack
	cd $(cmake.dir) && \
	CFLAGS="$(CFLAGS)" CXXFLAGS="$(CXXFLAGS)" sh configure $(.cmake.args)  && \
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

GLOBAL_CLEAN += .cmake.clean
