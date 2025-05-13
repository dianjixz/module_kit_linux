# MODULE_LLM_LINUX
Patch for the Linux kernel adapted for the module_llm development board.  
Compilation will automatically download and apply the relevant patches to compile into a kernel project.  

auto compile:
```bash
source /opt/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bash.bashrc
make distclean
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- m5stack_AX630C_emmc_arm64_k419_defconfig 
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j `nproc` 
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- m5stack-ax630c-lite.dtb 
axp_pack_bin build/linux-4.19.125/arch/arm64/boot/Image boot_signed.bin
axp_pack_bin build/linux-4.19.125/arch/arm64/boot/dts/m5stack-ax630c-lite.dtb AX630C_emmc_arm64_k419_signed.dtb
```

just Extract:
```bash
make Extracting
```

just Patch:
```bash
make Patching
```

just Configur:
```bash
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Configuring
```