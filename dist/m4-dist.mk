## m4-dist.mk: this file is part of the SL packager.
## 
## Copyright (C) 2010,2011 The SL project.
## All rights reserved. 

include common.mk
include dist-common.mk

M4_GIT_BRANCH = branch-1.6

M4_GIT_HASH := $(strip $(shell $(GIT) ls-remote $(M4_REPO) $(M4_GIT_BRANCH)|head -n1|cut -c1-6))
M4_DISTBASE = m4-$(M4_GIT_HASH)
M4_METASRC = $(META_SOURCES)/$(M4_DISTBASE)

$(M4_METASRC)/download_done:
	rm -f $@
	$(MKDIR_P) $(META_SOURCES)
	cd $(META_SOURCES) && $(GIT) clone $(M4_REPO) $(M4_DISTBASE)
	cd $(M4_METASRC) && $(GIT) checkout -b $(M4_GIT_BRANCH) origin/$(M4_GIT_BRANCH)
	touch $@

$(M4_METASRC)/patch_done: $(M4_METASRC)/download_done
	rm -f $@
	cd $(M4_METASRC) && patch -p1 <$$OLDPWD/patches/m4.patch
	touch $@

$(M4_METASRC)/bootstrap_done: $(M4_METASRC)/patch_done
	rm -f $@
	cd $(M4_METASRC) && bash -e ./bootstrap
	touch $@

$(M4_METASRC)/configure_done: $(M4_METASRC)/bootstrap_done
	rm -f $@
	cd $(M4_METASRC) && ./configure
	touch $@

$(M4_METASRC)/build1_done: $(M4_METASRC)/configure_done
	rm -f $@
	cd $(M4_METASRC) && $(MAKE)
	touch $@

.PHONY: m4-dist
m4-dist: $(M4_METASRC)/build1_done
	$(MKDIR_P) $(ARCHIVEDIR)
	rm -f $(M4_METASRC)/*.tar.*
	cd $(M4_METASRC) && make dist
	for arch in $(M4_METASRC)/*.tar.bz2; do \
	   bn=`basename $$arch`; \
	   if ! test -f $(ARCHIVEDIR)/$$bn; then \
	      mv -f $$arch $(ARCHIVEDIR)/; \
	   fi; \
	done

