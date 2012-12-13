repmgr.version := 1.2.0
repmgr.dir := repmgr-$(repmgr.version)
repmgr.tgz := $(repmgr.dir).tar.gz

.repmgr.args := \
	--prefix=$(pfx)

.repmgr.unpack: $(repmgr.tgz)
	tar xvf $^ && touch $(CWD)/$@

.repmgr.make: .repmgr.unpack
	cd $(repmgr.dir) && \
	PATH=$(pfx)/bin:$(PATH) $(MAKE) USE_PGXS=1 -j4 && \
	touch $(CWD)/$@

.repmgr.install: .repmgr.make
	cd $(repmgr.dir) && \
	PATH=$(pfx)/bin:$(PATH) $(MAKE) USE_PGXS=1 -j4 install $(DEST) && \
	touch $(CWD)/$@

.repmgr.clean:
	rm -rf $(repmgr.dir) .repmgr.*
