yaml.version := 0.1.4
yaml.dir := yaml-$(yaml.version)
yaml.tgz := $(yaml.dir).tar.gz

.yaml.args := \
	--prefix=$(pfx)

.yaml.unpack: $(yaml.tgz)
	tar xvf $^ && touch $(CWD)/$@

.yaml.config: .yaml.unpack
	cd $(yaml.dir) && \
	CFLAGS="$(CFLAGS)" CXXFLAGS="$(CFLAGS)" sh configure $(.yaml.args)  && \
	touch $(CWD)/$@

.yaml.make: .yaml.config
	cd $(yaml.dir) && \
	$(MAKE) -j4 && \
	touch $(CWD)/$@

.yaml.install: .yaml.make
	cd $(yaml.dir) && \
	make install $(DEST) && \
	touch $(CWD)/$@

.yaml.clean:
	rm -rf $(yaml.dir) .yaml.*
GLOBAL_CLEAN += .yaml.clean
