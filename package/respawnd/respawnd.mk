#############################################################
#
# respawnd
#
#############################################################

# Current version, use the latest unless there are any known issues.
RESPAWND_VERSION=R1_3_3
# The filename of the package to download.
RESPAWND_SOURCE=apps-sys-utils-respawnd-$(RESPAWND_VERSION).tar.gz
# The site and path to where the source packages are.
RESPAWND_SITE=http://support.ctekproducts.com/source
# The directory which the source package is extracted to.
RESPAWND_BASEDIR=$(BUILD_DIR)/apps/sys-utils/respawnd
RESPAWND_DIR=$(RESPAWND_BASEDIR)-$(RESPAWND_VERSION)
# Which decompression to use, BZCAT or ZCAT.
RESPAWND_CAT:=$(ZCAT)
# Target binary for the package.
RESPAWND_BINARY:=respawnd
# Not really needed, but often handy define.
RESPAWND_TARGET_BINARY:=/sbin/$(RESPAWND_BINARY)

# The download rule. Main purpose is to download the source package.
$(DL_DIR)/$(RESPAWND_SOURCE):
	$(WGET) -P $(DL_DIR) $(RESPAWND_SITE)/$(RESPAWND_SOURCE)

# The unpacking rule. Main purpose is to extract the source package, apply any
# patches and update config.guess and config.sub.
$(RESPAWND_DIR)/.unpacked: $(DL_DIR)/$(RESPAWND_SOURCE)
	$(RESPAWND_CAT) $(DL_DIR)/$(RESPAWND_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
#	toolchain/patch-kernel.sh $(RESPAWND_DIR) package/respawnd/ respawnd-$(RESPAWND_VERSION)-\*.patch\*
#	$(CONFIG_UPDATE) $(RESPAWND_DIR)
	ln -s $(RESPAWND_DIR) $(RESPAWND_BASEDIR)
	touch $@

# configure rule:
# respawnd doesn't need to be configured so just touch .configured
$(RESPAWND_DIR)/.configured:	$(RESPAWND_DIR)/.unpacked
	touch $(RESPAWND_DIR)/.configured

# build respawnd by invoking the package make
# the resulting binary isn't stripped (I think the AXIS build system
# does this as part of the install procedure) so I add it here
$(RESPAWND_DIR)/$(RESPAWND_BINARY): $(RESPAWND_DIR)/.configured
	$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(RESPAWND_DIR)


# The installing rule. Main purpose is to install the binary into the target
# root directory and make sure it is stripped from debug symbols to reduce the
# space requirements to a minimum.
#
# Only the files needed to run the application should be installed to the
# target root directory, to not waste valuable flash space.
$(TARGET_DIR)/$(RESPAWND_TARGET_BINARY): $(RESPAWND_DIR)/$(RESPAWND_BINARY)
	$(INSTALL) $(RESPAWND_DIR)/respawnd $@
	$(STRIPCMD) --strip-unneeded $@
	ln -sf /sbin/respawnd $(TARGET_DIR)/sbin/respawn-on
	ln -sf /sbin/respawnd $(TARGET_DIR)/sbin/respawn-off

# Main rule which shows which other packages must be installed before the respawnd
# package is installed. This to ensure that all depending libraries are
# installed.
respawnd:	uclibc $(TARGET_DIR)/$(RESPAWND_TARGET_BINARY)

# Source download rule. Main purpose to download the source package. Since some
# people would like to work offline, it is mandotory to implement a rule which
# downloads everything this package needs.
respawnd-source: $(DL_DIR)/$(RESPAWND_SOURCE)

# Clean rule. Main purpose is to clean the build directory, thus forcing a new
# rebuild the next time Buildroot is made.
respawnd-clean: respawnd-init-clean
	$(MAKE) -C $(RESPAWND_DIR) clean

# Directory clean rule. Main purpose is to remove the build directory, forcing
# a new extraction, patching and rebuild the next time Buildroot is made.
respawnd-dirclean:
	rm -rf $(RESPAWND_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
# This is how the respawnd package is added to the list of rules to build.
ifeq ($(strip $(BR2_PACKAGE_RESPAWND)),y)
TARGETS+=respawnd
TARGETS+=respawnd-init
endif
