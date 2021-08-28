#############################################################
#
# ctekdiag
#
#############################################################

# Current version, use the latest unless there are any known issues.
CTEKDIAG_VERSION=R1_0_0
# The filename of the package to download.
CTEKDIAG_SOURCE=apps-ctekdiag-$(CTEKDIAG_VERSION).tar.gz
# The site and path to where the source packages are.
#CTEKDIAG_SITE=http://support.ctekproducts.com/source
CTEKDIAG_SITE=https://github.com/statusbits/statusbits.github.io/raw/master/archive
# The directory which the source package is extracted to.
CTEKDIAG_BASEDIR=$(BUILD_DIR)/apps/ctekdiag
CTEKDIAG_DIR=$(CTEKDIAG_BASEDIR)-$(CTEKDIAG_VERSION)
# Which decompression to use, BZCAT or ZCAT.
CTEKDIAG_CAT:=$(ZCAT)
# Target binary for the package.
CTEKDIAG_BINARY:=ctekdiag
# Not really needed, but often handy define.
CTEKDIAG_TARGET_BINARY:=/usr/sbin/$(CTEKDIAG_BINARY)

MY_TARGET_CONFIGURE_OPTS=$(TARGET_CONFIGURE_OPTS)
MY_TARGET_CONFIGURE_OPTS+=" INSTALL=$(INSTALL)"

# The download rule. Main purpose is to download the source package.
$(DL_DIR)/$(CTEKDIAGSOURCE):
	$(WGET) -P $(DL_DIR) $(CTEKDIAG_SITE)/$(CTEKDIAG_SOURCE)

# The unpacking rule. Main purpose is to extract the source package, apply any
# patches and update config.guess and config.sub.
$(CTEKDIAG_DIR)/.unpacked: $(DL_DIR)/$(CTEKDIAG_SOURCE)
	$(CTEKDIAG_CAT) $(DL_DIR)/$(CTEKDIAG_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	ln -s $(CTEKDIAG_DIR) $(CTEKDIAG_BASEDIR)
	touch $@

# configure rule:
# ctekdiag doesn't need to be configured so just touch .configured
$(CTEKDIAG_DIR)/.configured: $(CTEKDIAG_DIR)/.unpacked
	touch $(CTEKDIAG_DIR)/.configured

# build ctekdiag by invoking the package make
# the resulting binary isn't stripped (I think the AXIS build system
# does this as part of the install procedure) so I add it here
$(CTEKDIAG_DIR): $(CTEKDIAG_DIR)/.configured
		$(MAKE) $(MY_TARGET_CONFIGURE_OPTS) -C $(CTEKDIAG_DIR) prefix=$(CTEKDIAG_TARGET_BINARY) install


# The installing rule. Main purpose is to install the binary into the target
# root directory and make sure it is stripped from debug symbols to reduce the
# space requirements to a minimum.
#
# Only the files needed to run the application should be installed to the
# target root directory, to not waste valuable flash space.
# $(TARGET_DIR)/$(CTEKDIAG_TARGET_BINARY): $(CTEKDIAG_DIR)/$(CTEKDIAG_BINARY)
#	$(INSTALL) $(CTEKDIAG_DIR)/ctekdiag $@
#	$(STRIPCMD) --strip-unneeded $@
#	$(INSTALL) -m 0644 $(CTEKDIAG_DIR)/ctekdiag.conf $(TARGET_DIR)/etc
#	$(INSTALL) -m 0644 $(CTEKDIAG_DIR)/ctekdiag.banner $(TARGET_DIR)/etc


# Main rule which shows which other packages must be installed before the ctekdiag
# package is installed. This to ensure that all depending libraries are
# installed.

ctekdiag:	uclibc $(CTEKDIAG_DIR) 
#$(MAKE) -C $(CTEKDIAG_DIR) install

# Source download rule. Main purpose to download the source package. Since some
# people would like to work offline, it is mandotory to implement a rule which
# downloads everything this package needs.
ctekdiag-source: $(DL_DIR)/$(CTEKDIAG_SOURCE)

# Clean rule. Main purpose is to clean the build directory, thus forcing a new
# rebuild the next time Buildroot is made.
ctekdiag-clean: ctekdiag-init-clean
	$(MAKE) -C $(CTEKDIAG_DIR) clean

# Directory clean rule. Main purpose is to remove the build directory, forcing
# a new extraction, patching and rebuild the next time Buildroot is made.
ctekdiag-dirclean:
	rm -rf $(CTEKDIAG_DIR)

