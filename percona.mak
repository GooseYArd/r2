# Percona-Server-5.5.28-rel29.2.tar.gz

percona.version := 5.5.28-rel29.2
percona.dir := Percona-Server-$(percona.version)
percona.tgz := $(percona.dir).tar.gz

percona.args := \
	-DCMAKE_INSTALL_PREFIX=$(pfx) \
	-DWITH_SSL=bundled \
	-DCMAKE_C_FLAGS="-I$(CWD)/$(libaio.dir)/src -L$(CWD)/$(libaio.dir)/src" \
	-DCMAKE_CXX_FLAGS="-I$(CWD)/$(libaio.dir)/src -L$(CWD)/$(libaio.dir)/src" \
	-DCMAKE_EXE_LINKER_FLAGS="-L$(CWD)/$(libaio.dir)/src -L$(CWD)/install/lib" \
	-DCMAKE_MODULE_LINKER_FLAGS="-L$(CWD)/$(libaio.dir)/src" \
	-DCMAKE_SHARED_LINKER_FLAGS="-L$(CWD)/$(libaio.dir)/src"

.percona.unpack: $(percona.tgz)
	tar xvf $^ && touch $(CWD)/$@

.percona.config: .cmake.install .percona.unpack .bison.install .openssl.install .zlib.install .libaio.install
	cd $(percona.dir) && \
	PATH=$(PATH):$(CWD)/install/bin && \
	cmake $(percona.args) . && \
	touch $(CWD)/$@

.percona.make: .percona.config
	cd $(percona.dir) && \
	make -j4 && \
	touch $(CWD)/$@

.percona.install: .percona.make
	cd $(percona.dir) && \
	make install $(DEST) && \
	touch $(CWD)/$@

.mysqlbench.make: .percona.config
	cd $(percona.dir)/contrib/mysqlbench && \
	make

.mysqlbench.install: .mysqlbench.make
	cd $(percona.dir)/contrib/mysqlbench && \
	make install

.percona.clean:
	rm -rf $(percona.dir) .percona.*
GLOBAL_CLEAN += .percona.clean
