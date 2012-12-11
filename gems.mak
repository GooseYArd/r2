GEM := $(pfx)/bin/gem

.gems.mysql.install:
	$(GEM) install gems-noauto/mysql-2.9.0.gem -- --with-mysql-config=$(pfx)/bin/mysql_config

.gems.install: .gems.mysql.install
	for i in gems/*; do $(GEM) install --no-ri --no-rdoc $$i; done
	touch $@

.gems.clean:
	rm -f .gems.*
