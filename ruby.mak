ruby.version := 1.9.3-p374
ruby.dir := ruby-$(ruby.version)
ruby.tgz := $(ruby.dir).tar.gz
ruby.url := http://ftp.ruby-lang.org/pub/ruby/1.9/$(ruby.tgz)

$(ruby.tgz): ruby.sha1
	wget $(ruby.url)
	sha1sum -c $<

.ruby.args := \
	--prefix=$(pfx)

.ruby.unpack: $(ruby.tgz)
	tar xvf $^ && touch $(CWD)/$@

.ruby.config: .ruby.unpack .yaml.install .openssl.install
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

GLOBAL_CLEAN += .ruby.clean

.ruby.distclean:
	rm -f $(ruby.tgz)
GLOBAL_DISTCLEAN += .ruby.distclean