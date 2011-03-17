## mgsim.mk: this file is part of the SL tool chain installer.
## 
## Copyright (C) 2010,2011 The SL project.
##
## This program is free software; you can redistribute it and/or
## modify it under the terms of the GNU General Public License
## as published by the Free Software Foundation; either version 2
## of the License, or (at your option) any later version.
##
## The complete GNU General Public Licence Notice can be found as the
## `COPYING' file in the root directory.
##

MGSIM_SRC = $(SRCBASE)/mgsim-$(MGSIM_VERSION)
MGSIM_BUILD = $(BLDBASE)/mgsim-$(MGSIM_VERSION)

MGSIM_CFG_TARGETS = $(MGSIM_BUILD)/configure_done
MGSIM_BUILD_TARGETS = $(MGSIM_BUILD)/build_done
MGSIM_INST_TARGETS = $(SLDIR)/.mgsim-installed

MGSIM_TARGET_SELECT =
if ENABLE_MTALPHA
MGSIM_TARGET_SELECT += --enable-mtalpha
else
MGSIM_TARGET_SELECT += --disable-mtalpha
endif
if ENABLE_MTSPARC
MGSIM_TARGET_SELECT += --enable-mtsparc
else
MGSIM_TARGET_SELECT += --disable-mtsparc
endif

.PRECIOUS: $(MGSIM_ARCHIVE) $(MGSIM_CFG_TARGETS) $(MGSIM_BUILD_TARGETS) $(MGSIM_INST_TARGETS)

mgsim-fetch: $(MGSIM_ARCHIVE) ; $(RULE_DONE)
mgsim-configure: $(MGSIM_CFG_TARGETS) ; $(RULE_DONE)
mgsim-build: $(MGSIM_BUILD_TARGETS) ; $(RULE_DONE)
mgsim-install: $(MGSIM_INST_TARGETS) ; $(RULE_DONE)

$(MGSIM_SRC)/configure: $(MGSIM_ARCHIVE)
	rm -f $@
	$(UNTAR) $(SRCBASE) $(MGSIM_ARCHIVE)
	touch $@

$(MGSIM_BUILD)/configure_done: $(MGSIM_SRC)/configure $(SLTAG) $(BINUTILS_INST_TARGETS)
	rm -f $@
	$(MKDIR_P) $(MGSIM_BUILD)
	cd $(DSTBASE) && rm -f slreqs-$(SLNAME) && $(LN_S) $(REQNAME) slreqs-$(SLNAME)
	SRC=$$(cd $(MGSIM_SRC) && pwd) && \
	   cd $(MGSIM_BUILD) && \
	   PATH=$(REQCURRENT)/bin:$$PATH $$SRC/configure --prefix=$(SLDIR) \
			  CC="$(CC)" CXX="$(CXX)" \
	                  CPPFLAGS="$(CPPFLAGS)" \
			  CFLAGS="$(CFLAGS)" CXXFLAGS="$(CXXFLAGS)" \
	                  LDFLAGS="$(LDFLAGS)" \
	                  $(MGSIM_TARGET_SELECT)
	rm -f $(MGSIM_BUILD)/src/*main.o
	touch $@

$(MGSIM_BUILD)/build_done: $(MGSIM_BUILD)/configure_done
	rm -f $@
	cd $(MGSIM_BUILD) && $(MAKE) all
	touch $@

$(SLDIR)/.mgsim-installed: $(MGSIM_BUILD)/build_done
	rm -f $@
	cd $(MGSIM_BUILD) && $(MAKE) install
	touch $@

