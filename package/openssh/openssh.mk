#############################################################
#
# openssh
#
#############################################################

OPENSSH_VERSION = 6.1p1
OPENSSH_SITE = http://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable
OPENSSH_CONF_ENV = LD="$(TARGET_CC)" LDFLAGS="$(TARGET_CFLAGS)"
OPENSSH_CONF_OPT = --libexecdir=/usr/lib --disable-lastlog --disable-utmp \
		--disable-utmpx --disable-wtmp --disable-wtmpx --disable-strip

OPENSSH_DEPENDENCIES = zlib openssl

define OPENSSH_INSTALL_INITSCRIPT
	$(INSTALL) -D -m 755 package/openssh/S50sshd $(TARGET_DIR)/etc/init.d/S50sshd
	$(INSTALL) -D -m 600 package/openssh/keys/* $(TARGET_DIR)/etc/
	$(INSTALL) -D -m 644 package/openssh/keys.pub/* $(TARGET_DIR)/etc/
	$(INSTALL) -D -m 644 package/openssh/local_config/* $(TARGET_DIR)/etc/
endef

OPENSSH_POST_INSTALL_TARGET_HOOKS += OPENSSH_INSTALL_INITSCRIPT

$(eval $(autotools-package))
