GEM := $(pfx)/bin/gem

.gems.install:
	for i in gems/*; do install/bin/gem install --no-ri --no-rdoc $$i; done
	touch $@

.gems.clean:
	rm -f .gems.*
