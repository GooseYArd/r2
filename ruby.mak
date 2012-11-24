ruby.version := 1.9.3-p327
ruby.dir := ruby-$(ruby.version)
ruby.tgz := $(ruby.dir).tar.gz

.ruby.args := \
	--prefix=$(pfx)

.ruby.unpack: $(ruby.tgz)
	tar xvf $^ && touch $(CWD)/$@

.ruby.config: .ruby.unpack .yaml.install .ssl.install .readline.install .ncurses.install
	cd $(ruby.dir) && \
	LDFLAGS="$(LDFLAGS)" CFLAGS="$(CFLAGS)" CXXFLAGS="$(CFLAGS)" ./configure $(.ruby.args)  && \
	touch $(CWD)/$@

.ruby.make: .ruby.config
	cd $(ruby.dir) && \
	$(MAKE) -j4 && \
	touch $(CWD)/$@

.ruby.install: .ruby.make
	cd $(ruby.dir) && \
	make install $(DEST) && \
	touch $(CWD)/$@

.ruby.clean:
	rm -rf $(ruby.dir) .ruby.*

