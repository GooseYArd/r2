libyaml.version := 0.1.4
libyaml.dir := yaml-$(libyaml.version)
libyaml.tgz := $(libyaml.dir).tar.gz
libyaml.url := http://pylibyaml.org/download/libyaml/$(libyaml.tgz)

.libyaml.args := \
	--prefix=$(pfx)

$(libyaml.tgz):
	wget $(libyaml.url)

.libyaml.unpack: $(libyaml.tgz) libyaml.sha1
	sha1sum -c libyaml.sha1
	tar xvf $< && touch $(CWD)/$@

.libyaml.config: .libyaml.unpack
	cd $(libyaml.dir) && \
	CFLAGS="$(CFLAGS)" CXXFLAGS="$(CFLAGS)" sh configure $(.libyaml.args)  && \
	touch $(CWD)/$@

.libyaml.make: .libyaml.config
	cd $(libyaml.dir) && \
	$(MAKE) -j4 && \
	touch $(CWD)/$@

.libyaml.install: .libyaml.make
	cd $(libyaml.dir) && \
	make install $(DEST) && \
	touch $(CWD)/$@

.libyaml.clean:
	rm -rf $(libyaml.dir) .libyaml.*
GLOBAL_CLEAN += .libyaml.clean

.libyaml.distclean:
	rm -f $(libyaml.tgz)

GLOBAL_DISTCLEAN += .libyaml.distclean