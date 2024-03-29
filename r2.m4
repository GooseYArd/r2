define(`R2_DISTS', `dists')dnl
define(`R2_BUILD', `build')dnl
define(`R2_SHA1DIR', `shasums')dnl
define(`R2_DECLS',
R2_PKG.version := R2_VERSION
R2_PKG.dir := R2_DIR
R2_PKG.tgz := R2_DIST
R2_PKG.url := R2_URL
)dnl
dnl
define(`R2_RULE_FETCH',
.R2_PKG.fetch:
	cd R2_DISTS && wget -N $(R2_PKG.url)
	touch -a $(CWD)/.R2_PKG.fetch
)dnl
dnl
define(`R2_CFG_ARGS',
R2_PKG.args := \
	--prefix=$(pfx)
)dnl
dnl
define(`R2_RULE_UNPACK',
.R2_PKG.unpack: .R2_PKG.fetch R2_SHA1DIR/R2_PKG.sha1
	cd $(CWD)/R2_DISTS && sha1sum -c $(CWD)/R2_SHA1DIR/R2_PKG.sha1
	cd $(CWD)/R2_BUILD && tar xvf $(CWD)/R2_DISTS/$(R2_PKG.tgz) && touch $(CWD)/.R2_PKG.unpack
)dnl
dnl
define(`R2_RULE_CONFIG',
.R2_PKG.config: .R2_PKG.unpack
	cd R2_BUILD/$(R2_PKG.dir) && \
	CFLAGS="$(CFLAGS)" CXXFLAGS="$(CFLAGS)" ./configure $(R2_PKG.args)  && \
	touch $(CWD)/.R2_PKG.config
)dnl
dnl
define(`R2_RULE_MAKE',
.R2_PKG.make: .R2_PKG.config
	cd R2_BUILD/$(R2_PKG.dir) && \
	$(MAKE) -j4 && \
	touch $(CWD)/.R2_PKG.make
)dnl
dnl
define(`R2_RULE_INSTALL',
.R2_PKG.install: .R2_PKG.make
	cd R2_BUILD/$(R2_PKG.dir) && \
	make install $(DEST) && \
	touch $(CWD)/.R2_PKG.install
)dnl
dnl
define(`R2_RULE_CLEAN',
.R2_PKG.clean:
	rm -rf R2_BUILD/$(R2_PKG.dir) .R2_PKG.*
GLOBAL_CLEAN += .R2_PKG.clean

.R2_PKG.distclean:
	rm -f R2_DISTS/$(R2_PKG.tgz)

GLOBAL_DISTCLEAN += .R2_PKG.distclean
)dnl
dnl
define(R2_DEFAULT_RULES_NOINSTALL,
R2_DECLS
R2_RULE_FETCH
R2_RULE_UNPACK
R2_RULE_CLEAN
)dnl
define(R2_DEFAULT_RULES_NOCONFIG,
R2_DECLS
R2_RULE_FETCH
R2_RULE_UNPACK
R2_RULE_MAKE
R2_RULE_INSTALL
R2_RULE_CLEAN
)dnl
define(R2_DEFAULT_RULES,
R2_CFG_ARGS
R2_RULE_CONFIG
R2_DEFAULT_RULES_NOCONFIG
)dnl
