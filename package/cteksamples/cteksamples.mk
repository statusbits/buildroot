#############################################################
#
# cteksamples
#
#############################################################

# Current version, use the latest unless there are any known issues.
CTEKSAMPLES_VERSION=R1_0_0
# The filename of the package to download.
CTEKSAMPLES_SOURCE=apps-cteksamples-$(CTEKSAMPLES_VERSION).tar.gz
# The site and path to where the source packages are.
CTEKSAMPLES_SITE=http://support.ctekproducts.com/source
# The directory which the source package is extracted to.
CTEKSAMPLES_BASEDIR=$(BUILD_DIR)/apps/cteksamples
CTEKSAMPLES_DIR=$(CTEKSAMPLES_BASEDIR)-$(CTEKSAMPLES_VERSION)
# Which decompression to use, BZCAT or ZCAT.
CTEKSAMPLES_CAT:=$(ZCAT)
# Target binary for the package.
CTEKSAMPLES_BINARY:=cteksamples
# Not really needed, but often handy define.
CTEKSAMPLES_TARGET_BINARY:=$(TARGET_DIR)/usr/sbin/

MY_TARGET_CONFIGURE_OPTS=$(TARGET_CONFIGURE_OPTS)
MY_TARGET_CONFIGURE_OPTS+=" INSTALL=$(INSTALL)"

# The download rule. Main purpose is to download the source package.
$(DL_DIR)/$(CTEKSAMPLES_SOURCE):
	$(WGET) -P $(DL_DIR) $(CTEKSAMPLES_SITE)/$(CTEKSAMPLES_SOURCE)

# The unpacking rule. Main purpose is to extract the source package, apply any
# patches and update config.guess and config.sub.
# The unpacking rule. Main purpose is to extract the source package, apply any
# patches and update config.guess and config.sub.
$(CTEKSAMPLES_DIR)/.unpacked: $(DL_DIR)/$(CTEKSAMPLES_SOURCE)
	$(CTEKSAMPLES_CAT) $(DL_DIR)/$(CTEKSAMPLES_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	ln -s $(CTEKSAMPLES_DIR) $(CTEKSAMPLES_BASEDIR)
#	toolchain/patch-kernel.sh $(CTEKSAMPLES_DIR) package/cteksamples/ cteksamples-$(CTEKSAMPLES_VERSION)-\*.patch\*
#	$(CONFIG_UPDATE) $(CTEKSAMPLES_DIR)
	touch $@

# configure rule:
# cteksamples doesn't need to be configured so just touch .configured
$(CTEKSAMPLES_DIR)/.configured: $(CTEKSAMPLES_DIR)/.unpacked
	touch $(CTEKSAMPLES_DIR)/.configured

# build cteksamples by invoking the package make
# the resulting binary isn't stripped (I think the AXIS build system
# does this as part of the install procedure) so I add it here
$(CTEKSAMPLES_DIR): $(CTEKSAMPLES_DIR)/.configured
	$(MAKE) $(MY_TARGET_CONFIGURE_OPTS) -C $(CTEKSAMPLES_DIR) prefix=$(CTEKSAMPLES_TARGET_BINARY) install

# The installing rule. Main purpose is to install the binary into the target
# root directory and make sure it is stripped from debug symbols to reduce the
# space requirements to a minimum.
#
# Only the files needed to run the application should be installed to the
# target root directory, to not waste valuable flash space.
# $(TARGET_DIR)/$(CTEKSAMPLES_TARGET_BINARY): $(CTEKSAMPLES_DIR)/$(CTEKSAMPLES_BINARY)
#	$(INSTALL) $(CTEKSAMPLES_DIR)/cteksamples $@
#	$(STRIPCMD) --strip-unneeded $@
#	$(INSTALL) -m 0644 $(CTEKSAMPLES_DIR)/cteksamples.conf $(TARGET_DIR)/etc
#	$(INSTALL) -m 0644 $(CTEKSAMPLES_DIR)/cteksamples.banner $(TARGET_DIR)/etc


# Main rule which shows which other packages must be installed before the cteksamples
# package is installed. This to ensure that all depending libraries are
# installed.

cteksamples:	uclibc $(CTEKSAMPLES_DIR)
#	$(MAKE) -C $(CTEKSAMPLES_DIR) install

# Source download rule. Main purpose to download the source package. Since some
# people would like to work offline, it is mandotory to implement a rule which
# downloads everything this package needs.
cteksamples-source: $(DL_DIR)/$(CTEKSAMPLES_SOURCE)

# Clean rule. Main purpose is to clean the build directory, thus forcing a new
# rebuild the next time Buildroot is made.
cteksamples-clean: cteksamples-init-clean
	$(MAKE) -C $(CTEKSAMPLES_DIR) clean

# Directory clean rule. Main purpose is to remove the build directory, forcing
# a new extraction, patching and rebuild the next time Buildroot is made.
cteksamples-dirclean:
	rm -rf $(CTEKSAMPLES_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
# This is how the respawnd package is added to the list of rules to build.
ifeq ($(strip $(BR2_CTEK_SAMPLES)),y)
TARGETS+=cteksamples
endif