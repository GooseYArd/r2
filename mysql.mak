mysql.version := 5.6.8-rc
mysql.dir := mysql-$(mysql.version)
mysql.tgz := $(mysql.dir).tar.gz

.mysql.args := \
	-DBUILD_CONFIG=mysql_release \
	-DCMAKE_INSTALL_PREFIX=$(pfx) \
	-DWITH_READLINE=1 \
	-DWITH_SSL=bundled

.mysql.unpack: $(mysql.tgz)
	tar xvf $^ && touch $(CWD)/$@

.mysql.config: .mysql.unpack .openssl.install .readline.install .zlib.install
	cd $(mysql.dir) && \
	touch $(CWD)/$@

.mysql.make: .mysql.config .cmake.install
	cd $(mysql.dir) && \
	CFLAGS=$(CFLAGS) CXXFLAGS=$(CXXFLAGS) cmake $(mysql.args) . && \
	touch $(CWD)/$@

.mysql.install: .mysql.make
	cd $(mysql.dir) && \
	make install $(DEST) && \
	touch $(CWD)/$@

.mysqlbench.make: .mysql.config
	cd $(mysql.dir)/contrib/mysqlbench && \
	make

.mysqlbench.install: .mysqlbench.make
	cd $(mysql.dir)/contrib/mysqlbench && \
	make install

.mysql.clean:
	rm -rf $(mysql.dir) .mysql.*
