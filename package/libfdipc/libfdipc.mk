#############################################################
#
# libfdipc
#
#############################################################
LIBFDIPC_VERSION=R1_1_1
LIBFDIPC_SOURCE=libs-libfdipc-$(LIBFDIPC_VERSION).tar.bz2
LIBFDIPC_SITE="http://support.ctekproducts.com/source"
LIBFDIPC_DIR=$(BUILD_DIR)/libfdipc-$(LIBFDIPC_VERSION)
MY_TARGET_CONFIGURE_OPTS=$(TARGET_CONFIGURE_OPTS)
MY_TARGET_CONFIGURE_OPTS+=" INSTALL=$(INSTALL)"

LIBFDIPC_ARCH:=$(ARCH)
LIBFDIPC_MAKEOPTS:= $(TARGET_CONFIGURE_OPTS) CC=$(TARGET_CC) CFLAGS="$(TARGET_CFLAGS) -nostdlib -nostartfiles -I. -fPIC" LDFLAGS="$(TARGET_LDFLAGS)"

$(DL_DIR)/$(LIBFDIPC_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBFDIPC_SITE)/$(LIBFDIPC_SOURCE)


$(LIBFDIPC_DIR)/.unpacked: $(DL_DIR)/$(LIBFDIPC_SOURCE)
	$(BZCAT) $(DL_DIR)/$(LIBFDIPC_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	touch $@

$(LIBFDIPC_DIR)/.configured: $(LIBFDIPC_DIR)/.unpacked 
	touch $(LIBFDIPC_DIR)/.configured

$(LIBFDIPC_DIR)/src/libfdipc.so: $(LIBFDIPC_DIR)/.configured
	$(MAKE) $(MY_TARGET_CONFIGURE_OPTS) -C $(LIBFDIPC_DIR) $(LIBFDIPC_MAKEOPTS)

$(STAGING_DIR)/usr/lib/libfdipc.so: $(LIBFDIPC_DIR)/src/libfdipc.so
	$(MAKE) $(MY_TARGET_CONFIGURE_OPTS) -C $(LIBFDIPC_DIR) $(LIBFDIPC_MAKEOPTS) prefix=$(STAGING_DIR)/usr install

$(TARGET_DIR)/usr/lib/libfdipc.so: $(STAGING_DIR)/usr/lib/libfdipc.so
	cp -dpf $(STAGING_DIR)/usr/lib/libfdipc.so* $(TARGET_DIR)/usr/lib/
	-$(STRIPCMD) $(STRIP_STRIP_UNNEEDED) $(TARGET_DIR)/usr/lib/libfdipc.so

libfdipc: uclibc $(TARGET_DIR)/usr/lib/libfdipc.so

libfdipc-source: $(DL_DIR)/$(LIBFDIPC_SOURCE)

libfdipc-clean:
	-$(MAKE) -C $(LIBFDIPC_DIR) $(LIBFDIPC_MAKEOPTS) clean

libfdipc-dirclean:
	rm -rf $(LIBFDIPC_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_LIBFDIPC)),y)
TARGETS+=libfdipc
endif
