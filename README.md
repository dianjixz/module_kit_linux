# MODULE_LLM_LINUX
Patch for the Linux kernel adapted for the module_llm development board.  
Compilation will automatically download and apply the relevant patches to compile into a kernel project.  

auto compile:
```bash
make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- m5stack_AX630C_emmc_arm64_k419_defconfig
make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- -j `nproc`
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
make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- Configuring
```