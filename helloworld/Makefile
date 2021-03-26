#CROSS_BUILD =
#CROSS_BUILD = /root/compile/arm-hisiv200-linux
PLATFORM_TYPE = x86-x64
#PLATFORM_TYPE = aarch64-linux-gnu
BUILD_DIR = build/$(PLATFORM_TYPE)

.PHONY : build
build:
	@echo "Do build cmd, Compile: ${PLATFORM_TYPE}, BuildDir: build/$(PLATFORM_TYPE) "
	@$(DOCKER_NAME) cmake -B$(BUILD_DIR) -H. -DBUILD_TARGET=build -DPLATFORM_TYPE=$(PLATFORM_TYPE)
	@$(DOCKER_NAME) make -C $(BUILD_DIR)

# Clean out the build directory
.PHONY : clean
clean:
	@echo "Do clean cmd, Compile: ${PLATFORM_TYPE}, BuildDir: build/$(PLATFORM_TYPE) "
	@rm -rf $(BUILD_DIR)/*
	@rm -rf out/$(PLATFORM_TYPE)/*

