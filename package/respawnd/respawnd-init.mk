#############################################################
#
# respawnd
#
#############################################################

# Current version, use the latest unless there are any known issues.
RESPAWND_INIT_VERSION=R1_0_2
# The filename of the package to download.
RESPAWND_INIT_SOURCE=packages-initscripts-respawnd-$(RESPAWND_INIT_VERSION).tar.gz
# The site and path to where the source packages are.
RESPAWND_INIT_SITE=http://support.ctekproducts.com/source
# The directory which the source package is extracted to.
RESPAWND_INIT_DIR=$(BUILD_DIR)/packages/initscripts/respawnd-$(RESPAWND_INIT_VERSION)
# Which decompression to use, BZCAT or ZCAT.
RESPAWND_INIT_CAT:=$(ZCAT)
# Target binary for the package.
RESPAWND_INIT_BINARY:=S01respawnd
# Not really needed, but often handy define.
RESPAWND_INIT_TARGET_BINARY:=/etc/init.d/S01respawnd


# The download rule. Main purpose is to download the source package.
$(DL_DIR)/$(RESPAWND_INIT_SOURCE):
	$(WGET) -P $(DL_DIR) $(RESPAWND_INIT_SITE)/$(RESPAWND_INIT_SOURCE)

# The unpacking rule. Main purpose is to extract the source package, apply any
# patches and update config.guess and config.sub.
$(RESPAWND_INIT_DIR)/.unpacked: $(DL_DIR)/$(RESPAWND_INIT_SOURCE)
	$(RESPAWND_INIT_CAT) $(DL_DIR)/$(RESPAWND_INIT_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	touch $@

# configure rule:
# respawnd doesn't need to be configured so just touch .configured
$(RESPAWND_INIT_DIR)/.configured: $(RESPAWND_INIT_DIR)/.unpacked
	touch $(RESPAWND_INIT_DIR)/.configured

# build respawnd by invoking the package make
# the resulting binary isn't stripped (I think the AXIS build system
# does this as part of the install procedure) so I add it here
$(RESPAWND_INIT_DIR)/$(RESPAWND_INIT_BINARY): $(RESPAWND_INIT_DIR)/.configured

# The installing rule. Main purpose is to install the binary into the target
# root directory and make sure it is stripped from debug symbols to reduce the
# space requirements to a minimum.
#
# Only the files needed to run the application should be installed to the
# target root directory, to not waste valuable flash space.
$(TARGET_DIR)/$(RESPAWND_INIT_TARGET_BINARY): $(RESPAWND_INIT_DIR)/$(RESPAWND_INIT_BINARY)
	$(INSTALL) $(RESPAWND_INIT_DIR)/rc $(TARGET_DIR)/$(RESPAWND_INIT_TARGET_BINARY)

# Main rule which shows which other packages must be installed before the respawnd
# package is installed. This to ensure that all depending libraries are
# installed.
respawnd-init:	uclibc $(TARGET_DIR)/$(RESPAWND_INIT_TARGET_BINARY)

# Source download rule. Main purpose to download the source package. Since some
# people would like to work offline, it is mandotory to implement a rule which
# downloads everything this package needs.
respawnd-init-source: $(DL_DIR)/$(RESPAWND_INIT_SOURCE)

# Clean rule. Main purpose is to clean the build directory, thus forcing a new
# rebuild the next time Buildroot is made.
respawnd-init-clean:
	rm -f $(TARGET_DIR)/$(RESPAWND_INIT_TARGET_BINARY)

# Directory clean rule. Main purpose is to remove the build directory, forcing
# a new extraction, patching and rebuild the next time Buildroot is made.
respawnd-init-dirclean:
	rm -rf $(RESPAWND_INIT_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
# This is how the respawnd package is added to the list of rules to build.
ifeq ($(strip $(BR2_PACKAGE_RESPAWND)),y)
TARGETS+=respawnd-init
endif
