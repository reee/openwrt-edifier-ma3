include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=tas571x
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define KernelPackage/sound-soc-tas571x
  SUBMENU:=Sound Support
  TITLE:=TAS571x audio amplifier support
  DEPENDS:=+kmod-sound-core +kmod-sound-soc-core +kmod-i2c-core +kmod-regmap-i2c
  FILES:=$(PKG_BUILD_DIR)/snd-soc-tas571x.ko
  AUTOLOAD:=$(call AutoLoad,60,snd-soc-tas571x)
  KCONFIG:=
endef

define KernelPackage/sound-soc-tas571x/description
  Kernel module for TAS571x audio power amplifiers
  (TAS5707, TAS5711, TAS5717, TAS5719, TAS5721, TAS5733, TAS5753)
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
	$(MAKE) -C "$(LINUX_DIR)" \
		$(KERNEL_MAKE_FLAGS) \
		M="$(PKG_BUILD_DIR)" \
		modules
endef

$(eval $(call KernelPackage,sound-soc-tas571x))