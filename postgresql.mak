pg.version := 9.2.1
pg.dir := postgresql-$(pg.version)
pg.tgz := $(pg.dir).tar.bz2

.pg.args := \
	--prefix=$(pfx)

.pg.unpack: $(pg.tgz)
	tar xvf $^ && touch $(CWD)/$@

.pg.config: .pg.unpack .ssl.install .readline.install .zlib.install
	cd $(pg.dir) && \
	LDFLAGS="$(LDFLAGS)" CFLAGS="$(CFLAGS) $(LDFLAGS)" CXXFLAGS="$(CFLAGS)" sh configure $(.pg.args)  && \
	touch $(CWD)/$@

.pg.make: .pg.config
	cd $(pg.dir) && \
	$(MAKE) -j4 && \
	touch $(CWD)/$@

.pg.install: .pg.make
	cd $(pg.dir) && \
	make install $(DEST) && \
	touch $(CWD)/$@

.pgbench.make: .pg.config
	cd $(pg.dir)/contrib/pgbench && \
	make

.pgbench.install: .pgbench.make
	cd $(pg.dir)/contrib/pgbench && \
	make install

.pg.clean:
	rm -rf $(pg.dir) .pg.*
