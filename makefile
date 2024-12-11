# SPDX-FileCopyrightText: 2024 M5Stack Technology CO LTD
#
# SPDX-License-Identifier: MIT

PATCH_DIR := patches
SRC_DIR := build/linux-4.19.125
PATCHES := $(wildcard patches/*.patch)
DTSS := $(wildcard linux-dts/*.dts*)
CONFIG_FILES := $(wildcard *.config)
LINUX_TAR_SHA := 839708f2798d71fde9f2fe6144b703a1641d215d9e463be2d57be9000151d3e1
# AX630C_KERNEL_PARAM := ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu-
# KERNEL_MAKE := cd $(SRC_DIR) ; $(MAKE) $(AX630C_KERNEL_PARAM)

KERNEL_MAKE := cd $(SRC_DIR) ; $(MAKE)

%:
	@ if [ "$(MAKECMDGOALS)" != "build_init" ] ; then \
		$(MAKE) build_init ; \
		[ -f '$(SRC_DIR)/drivers/soc/axera/osal/osal_all_code.o' ] || cp src_overlay/osal_all_code.o $(SRC_DIR)/drivers/soc/axera/osal/osal_all_code.o ; \
		$(KERNEL_MAKE)  $(MAKECMDGOALS) ; \
	fi

build_init:Configuring

Extracting:
	$(MAKE) build/check_build.tmp
	$(MAKE) build/check_dts.tmp

Patching:Extracting 
	$(MAKE) build/check_patch.tmp

Configuring:Patching 
	$(MAKE) build/check_config.tmp  

build/check_build.tmp:$(PATCHES)
	[ -d 'build' ] || mkdir build
	@if [ -f '.stamp_extracted' ] ; then \
		[ -f '../../../dl/linux-4.19.125.tar.gz' ] || wget --passive-ftp -nd -t 3 -O '../../../dl/linux-4.19.125.tar.gz' 'https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/snapshot/linux-4.19.125.tar.gz' ; \
		calculated_hash=$$(sha256sum ../../../dl/linux-4.19.125.tar.gz | awk '{ print $$1 }'); \
		if [ "$$calculated_hash" != "$(LINUX_TAR_SHA)" ]; then \
			rm ../../../dl/linux-4.19.125.tar.gz ; \
			exit 1; \
		fi ; \
		[ -d 'build/linux-4.19.125' ] || tar zxf ../../../dl/linux-4.19.125.tar.gz -C build/ ; \
	else \
		[ -f '.linux-4.19.125.tar.gz' ] || wget --passive-ftp -nd -t 3 -O '.linux-4.19.125.tar.gz' 'https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/snapshot/linux-4.19.125.tar.gz' ; \
		calculated_hash=$$(sha256sum .linux-4.19.125.tar.gz | awk '{ print $$1 }'); \
		if [ "$$calculated_hash" != "$(LINUX_TAR_SHA)" ]; then \
			rm .linux-4.19.125.tar.gz ; \
			exit 1; \
		fi ; \
		[ -d 'build/linux-4.19.125' ] || tar zxf .linux-4.19.125.tar.gz -C build/ ; \
	fi
	@[ -L 'arch' ] || ln -s $(SRC_DIR)/arch arch
	@[ -L 'scripts' ] || ln -s $(SRC_DIR)/scripts scripts
	@[ -L 'include' ] || ln -s $(SRC_DIR)/scripts include
	@rm -f build/check_build.tmp
	@touch build/check_build.tmp

build/check_dts.tmp:$(DTSS)
	@cp linux-dts/* $(SRC_DIR)/arch/arm64/boot/dts/
	@rm -f build/check_dts.tmp
	@touch build/check_dts.tmp

build/check_patch.tmp:$(PATCHES)
	@[ -d 'build/linux-4.19.125/arch/arm64/boot/dts/axera' ] || {\
		for patch in $^; do \
			echo "Applying $$patch..."; \
			patch -p1 -d $(SRC_DIR) <$$patch || { echo "Failed to apply $$patch"; exit 1; } \
		done ; \
	}
	@rm -f build/check_patch.tmp
	@touch build/check_patch.tmp

build/check_config.tmp:$(CONFIG_FILES)
	@[ -f '$(SRC_DIR)/arch/arm64/configs/m5stack_AX630C_emmc_arm64_k419_defconfig' ] || { cat $(SRC_DIR)/arch/arm64/configs/axera_AX630C_emmc_arm64_k419_defconfig fragment-03-systemd.config linux-disable.config linux-enable-m5stack.config > $(SRC_DIR)/arch/arm64/configs/m5stack_AX630C_emmc_arm64_k419_defconfig ; }
	@rm -f build/check_config.tmp
	@touch build/check_config.tmp

distclean:
	@rm -f build -rf
	@rm -f arch
	@rm -f scripts
	@rm -f include
	@rm -f .config
linux-distclean:
	@$(KERNEL_MAKE) distclean
	@rm -f build/check_config.tmp 
