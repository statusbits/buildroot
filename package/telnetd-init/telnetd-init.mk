#############################################################
#
# telnetd
# updated: 8/2/13 for buildroot2012
#############################################################

# Current version, use the latest unless there are any known issues.
TELNETD_INIT_VERSION=R1_0_0
# The filename of the package to download.
TELNETD_INIT_SOURCE=packages-initscripts-telnetd-$(TELNETD_INIT_VERSION).tar.gz
# The site and path to where the source packages are.
TELNETD_INIT_SITE="http://support.ctekproducts.com/source"
# The directory which the source package is extracted to.
TELNETD_INIT_DIR=$(BUILD_DIR)/packages/initscripts/telnetd-$(TELNETD_INIT_VERSION)
# Which decompression to use, BZCAT or ZCAT.
TELNETD_INIT_CAT:=$(ZCAT)
# Target binary for the package.
TELNETD_INIT_BINARY:=S50telnetd
# Not really needed, but often handy define.
TELNETD_INIT_TARGET_BINARY:=/etc/init.d/S50telnetd
TELNETD_INIT_TARGET_CONFIG:=/etc/conf.d/telnetd

# The download rule. Main purpose is to download the source package.
$(DL_DIR)/$(TELNETD_INIT_SOURCE):
	$(WGET) -P $(DL_DIR) $(TELNETD_INIT_SITE)/$(TELNETD_INIT_SOURCE)

# The unpacking rule. Main purpose is to extract the source package, apply any
# patches and update config.guess and config.sub.
$(TELNETD_INIT_DIR)/.unpacked: $(DL_DIR)/$(TELNETD_INIT_SOURCE)
	$(TELNETD_INIT_CAT) $(DL_DIR)/$(TELNETD_INIT_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
#	$(CONFIG_UPDATE) $(TELNETD_INIT_DIR)
	touch $@

# configure rule:
# telnetd doesn't need to be configured so just touch .configured
$(TELNETD_INIT_DIR)/.configured: $(TELNETD_INIT_DIR)/.unpacked
	touch $(TELNETD_INIT_DIR)/.configured

# build telnetd by invoking the package make
# the resulting binary isn't stripped (I think the AXIS build system
# does this as part of the install procedure) so I add it here
$(TELNETD_INIT_DIR)/$(TELNETD_INIT_BINARY): $(TELNETD_INIT_DIR)/.configured

# The installing rule. Main purpose is to install the binary into the target
# root directory and make sure it is stripped from debug symbols to reduce the
# space requirements to a minimum.
#
# Only the files needed to run the application should be installed to the
# target root directory, to not waste valuable flash space.
$(TARGET_DIR)/$(TELNETD_INIT_TARGET_BINARY): $(TELNETD_INIT_DIR)/$(TELNETD_INIT_BINARY)
	$(INSTALL) $(TELNETD_INIT_DIR)/rc $(TARGET_DIR)/$(TELNETD_INIT_TARGET_BINARY)
#	$(INSTALL) $(TELNETD_INIT_DIR)/conf $(TARGET_DIR)/$(TELNETD_INIT_TARGET_CONFIG)
# Main rule which shows which other packages must be installed before the telnetd
# package is installed. This to ensure that all depending libraries are
# installed.
telnetd-init:	uclibc $(TARGET_DIR)/$(TELNETD_INIT_TARGET_BINARY)

# Source download rule. Main purpose to download the source package. Since some
# people would like to work offline, it is mandotory to implement a rule which
# downloads everything this package needs.
telnetd-init-source: $(DL_DIR)/$(TELNETD_INIT_SOURCE)

# Clean rule. Main purpose is to clean the build directory, thus forcing a new
# rebuild the next time Buildroot is made.
telnetd-init-clean:
	rm -f $(TARGET_DIR)/$(TELNETD_INIT_TARGET_BINARY)

# Directory clean rule. Main purpose is to remove the build directory, forcing
# a new extraction, patching and rebuild the next time Buildroot is made.
telnetd-init-dirclean:
	rm -rf $(TELNETD_INIT_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
# This is how the telnetd package is added to the list of rules to build.
ifeq ($(strip $(BR2_PACKAGE_TELNETD)),y)
TARGETS+=telnetd-init
endif
