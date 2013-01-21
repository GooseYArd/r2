#node-v0.8.15.tar.gz

node.version := 0.8.18
node.dir := node-v$(node.version)
node.tgz := $(node.dir).tar.gz
node.url := http://nodejs.org/dist/v$(node.version)/$(node.tgz)

$(node.tgz): node.sha1
	wget $(node.url)
	sha1sum -c $<

.node.args := \
	--prefix=$(pfx)

.node.unpack: $(node.tgz)
	tar xvf $^ && touch $(CWD)/$@

.node.config: .node.unpack
	cd $(node.dir) && \
	CFLAGS="$(CFLAGS)" CXXFLAGS="$(CFLAGS)" ./configure $(.node.args)  && \
	touch $(CWD)/$@

.node.make: .node.config
	cd $(node.dir) && \
	$(MAKE) && \
	touch $(CWD)/$@

.node.install: .node.make
	cd $(node.dir) && \
	make install $(DEST) && \
	touch $(CWD)/$@

.node.clean:
	rm -rf $(node.dir) .node.*
GLOBAL_CLEAN += .node.clean
