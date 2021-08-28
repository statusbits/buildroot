#############################################################
#
# ctekg62x  - g62x Servers
#
#############################################################
CTEKG62X_DIR= apps_g62x
TARGET_OPTS=$(MY_TARGET_CONFIGURE_OPTS)
TARGET_OPTS+=" TARGET_DIR=$(TARGET_DIR)"

#$(CTEKG62X_DIR):
#	$(MAKE) $(MY_TARGET_CONFIGURE_OPTS) -C $(CTEKG62X_DIR) -f make_ctek_g62x

#ctekg62x: uclibc $(CTEKG62X_DIR)
ctekg62x:
	@echo '*************'
	@echo $(BUILD_DIR) PREFIX****** $(TARGET_DIR)
	$(MAKE) $(TARGET_OPTS) -C $(CTEKG62X_DIR) -f make_ctek_g62x install

ctekg62x-binary:
	$(MAKE) -C $(CTEKG62X_DIR) -f make_ctek_g62x install_binary

ctekg62x-clean:
	$(MAKE) -C $(CTEKG62X_DIR) -f make_ctek_g62x clean

ctekg62x-binary-clean:
	$(MAKE) -C $(CTEKG62X_DIR) -f make_ctek_g62x clean_binary

ctekg62x-cooperbuffer:
	$(MAKE) -C $(CTEKG62X_DIR)/cooperbuffer