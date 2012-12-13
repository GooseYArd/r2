GEM := $(pfx)/bin/gem

.gems.mysql.install: .percona.install
	$(GEM) install gems-noauto/mysql2-0.3.11.gem -- --with-mysql-config=$(pfx)/bin/mysql_config

.gems.install: .gems.mysql.install
	for i in gems/*; do $(GEM) install --no-ri --no-rdoc $$i; done
	touch $@

.gems.clean:
	rm -f .gems.*
