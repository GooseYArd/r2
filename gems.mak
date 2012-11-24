GEM := $(pfx)/bin/gem

.gems.install:
	for i in gems/*; do install/bin/gem install $$i; done
	touch $@

.gems.clean:
	rm -f .gems.*
