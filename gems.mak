GEM := $(pfx)/bin/gem

GEMS := $(wildcard gems/*)
GINST := $(foreach f, $(GEMS), gems/$(addsuffix .install, $(addprefix .gem., $(notdir $f))))

gems/.gem.%.install: gems/%
	$(GEM) install --no-ri --no-rdoc gems/$*
	touch $@

andy:
	echo $(GINST)

.gems.mysql.install: .percona.install
	$(GEM) install gems-noauto/mysql2-0.3.11.gem -- --with-mysql-config=$(pfx)/bin/mysql_config
	touch $@

.gems.nokogiri.install: .libxml2.install .libxslt.install
	$(GEM) install gems-noauto/nokogiri-1.5.5.gem -- --with-xml2-include=$(pfx)/include/libxml2 --with-xml2-lib=$(pfx)/lib --with-xslt-include=$(pfx)/include --with-xslt-lib=$(pfx)/lib
	touch $@

.gems.install: .gems.mysql.install .gems.nokogiri.install $(GINST)

.gems.clean:
	rm -f .gems.*
GLOBAL_CLEAN += .gems.clean
