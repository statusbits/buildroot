#############################################################
#
# vftpd
#
#############################################################

# Current version, use the latest unless there are any known issues.
VFTPD_VERSION=R1_2_8
# The filename of the package to download.
VFTPD_SOURCE=apps-vftpd-$(VFTPD_VERSION).tar.gz
# The site and path to where the source packages are.
VFTPD_SITE=http://support.ctekproducts.com/source
# The directory which the source package is extracted to.
VFTPD_BASEDIR=$(BUILD_DIR)/apps/vftpd
VFTPD_DIR=$(VFTPD_BASEDIR)-$(VFTPD_VERSION)
# Which decompression to use, BZCAT or ZCAT.
VFTPD_CAT:=$(ZCAT)
# Target binary for the package.
VFTPD_BINARY:=vftpd
# Not really needed, but often handy define.
VFTPD_TARGET_BINARY:=/bin/$(VFTPD_BINARY)

# The download rule. Main purpose is to download the source package.
$(DL_DIR)/$(VFTPD_SOURCE):
	$(WGET) -P $(DL_DIR) $(VFTPD_SITE)/$(VFTPD_SOURCE)

# The unpacking rule. Main purpose is to extract the source package, apply any
# patches and update config.guess and config.sub.
$(VFTPD_DIR)/.unpacked: $(DL_DIR)/$(VFTPD_SOURCE)
	$(VFTPD_CAT) $(DL_DIR)/$(VFTPD_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	ln -s $(VFTPD_DIR) $(VFTPD_BASEDIR)
	touch $@

# configure rule:
# vftpd doesn't need to be configured so just touch .configured
$(VFTPD_DIR)/.configured: $(VFTPD_DIR)/.unpacked
	touch $(VFTPD_DIR)/.configured

# build vftpd by invoking the package make
# the resulting binary isn't stripped (I think the AXIS build system
# does this as part of the install procedure) so I add it here
$(VFTPD_DIR)/$(VFTPD_BINARY): $(VFTPD_DIR)/.configured
	$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(VFTPD_DIR)

# The installing rule. Main purpose is to install the binary into the target
# root directory and make sure it is stripped from debug symbols to reduce the
# space requirements to a minimum.
#
# Only the files needed to run the application should be installed to the
# target root directory, to not waste valuable flash space.
$(TARGET_DIR)/$(VFTPD_TARGET_BINARY): $(VFTPD_DIR)/$(VFTPD_BINARY)
	$(INSTALL) $(VFTPD_DIR)/vftpd $@
	$(STRIPCMD) --strip-unneeded $@
	$(INSTALL) -m 0644 $(VFTPD_DIR)/vftpd.conf $(TARGET_DIR)/etc
	$(INSTALL) -m 0644 $(VFTPD_DIR)/vftpd.banner $(TARGET_DIR)/etc


# Main rule which shows which other packages must be installed before the vftpd
# package is installed. This to ensure that all depending libraries are
# installed.
vftpd:	uclibc $(TARGET_DIR)/$(VFTPD_TARGET_BINARY) vftpd-init

# Source download rule. Main purpose to download the source package. Since some
# people would like to work offline, it is mandotory to implement a rule which
# downloads everything this package needs.
vftpd-source: $(DL_DIR)/$(VFTPD_SOURCE)

# Clean rule. Main purpose is to clean the build directory, thus forcing a new
# rebuild the next time Buildroot is made.
vftpd-clean: vftpd-init-clean
	$(MAKE) -C $(VFTPD_DIR) clean

# Directory clean rule. Main purpose is to remove the build directory, forcing
# a new extraction, patching and rebuild the next time Buildroot is made.
vftpd-dirclean:
	rm -rf $(VFTPD_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
# This is how the vftpd package is added to the list of rules to build.
ifeq ($(strip $(BR2_PACKAGE_VFTPD)),y)
TARGETS+=libfdipc
TARGETS+=vftpd
endif
