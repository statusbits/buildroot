#############################################################
#
# vftpd
#
#############################################################

# Current version, use the latest unless there are any known issues.
VFTPD_INIT_VERSION=R1_3_1
# The filename of the package to download.
VFTPD_INIT_SOURCE=packages-initscripts-vftpd-$(VFTPD_INIT_VERSION).tar.gz
# The site and path to where the source packages are.
#VFTPD_INIT_SITE=http://support.ctekproducts.com/source
VFTPD_INIT_SITE=https://github.com/statusbits/statusbits.github.io/raw/master/archive
# The directory which the source package is extracted to.
VFTPD_INIT_DIR=$(BUILD_DIR)/packages/initscripts/vftpd-$(VFTPD_INIT_VERSION)
# Which decompression to use, BZCAT or ZCAT.
VFTPD_INIT_CAT:=$(ZCAT)
# Target binary for the package.
VFTPD_INIT_BINARY:=S60vftpd
# Not really needed, but often handy define.
VFTPD_INIT_TARGET_BINARY:=/etc/init.d/S55vftpd


# The download rule. Main purpose is to download the source package.
$(DL_DIR)/$(VFTPD_INIT_SOURCE):
	$(WGET) -P $(DL_DIR) $(VFTPD_INIT_SITE)/$(VFTPD_INIT_SOURCE)

# The unpacking rule. Main purpose is to extract the source package, apply any
# patches and update config.guess and config.sub.
$(VFTPD_INIT_DIR)/.unpacked: $(DL_DIR)/$(VFTPD_INIT_SOURCE)
	$(VFTPD_INIT_CAT) $(DL_DIR)/$(VFTPD_INIT_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	touch $@

# configure rule:
# vftpd doesn't need to be configured so just touch .configured
$(VFTPD_INIT_DIR)/.configured: $(VFTPD_INIT_DIR)/.unpacked
	touch $(VFTPD_INIT_DIR)/.configured

# build vftpd by invoking the package make
# the resulting binary isn't stripped (I think the AXIS build system
# does this as part of the install procedure) so I add it here
$(VFTPD_INIT_DIR)/$(VFTPD_INIT_BINARY): $(VFTPD_INIT_DIR)/.configured

# The installing rule. Main purpose is to install the binary into the target
# root directory and make sure it is stripped from debug symbols to reduce the
# space requirements to a minimum.
#
# Only the files needed to run the application should be installed to the
# target root directory, to not waste valuable flash space.
$(TARGET_DIR)/$(VFTPD_INIT_TARGET_BINARY): $(VFTPD_INIT_DIR)/$(VFTPD_INIT_BINARY)
	$(INSTALL) $(VFTPD_INIT_DIR)/rc $(TARGET_DIR)/$(VFTPD_INIT_TARGET_BINARY)
	echo FTP_ENABLED="yes" > $(VFTPD_INIT_DIR)/conf
	echo VFTPD_OPTIONS="-r" >> $(VFTPD_INIT_DIR)/conf
	$(INSTALL) -m 0644 $(VFTPD_INIT_DIR)/conf $(TARGET_DIR)/etc/conf.d/ftpd

# Main rule which shows which other packages must be installed before the vftpd
# package is installed. This to ensure that all depending libraries are
# installed.
vftpd-init:	uclibc $(TARGET_DIR)/$(VFTPD_INIT_TARGET_BINARY)

# Source download rule. Main purpose to download the source package. Since some
# people would like to work offline, it is mandotory to implement a rule which
# downloads everything this package needs.
vftpd-init-source: $(DL_DIR)/$(VFTPD_INIT_SOURCE)

# Clean rule. Main purpose is to clean the build directory, thus forcing a new
# rebuild the next time Buildroot is made.
vftpd-init-clean:
	rm -f $(TARGET_DIR)/$(VFTPD_INIT_TARGET_BINARY)

# Directory clean rule. Main purpose is to remove the build directory, forcing
# a new extraction, patching and rebuild the next time Buildroot is made.
vftpd-init-dirclean:
	rm -rf $(VFTPD_INIT_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
# This is how the vftpd package is added to the list of rules to build.
ifeq ($(strip $(BR2_PACKAGE_VFTPD)),y)
TARGETS+=vftpd-init
endif
