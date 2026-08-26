# ==============================================================================
# Master Makefile for Application & Vault CLI
# ==============================================================================

CC ?= gcc
CFLAGS ?= -Wall -Wextra -O2

# Directory definitions
ROOT_DIR := $(CURDIR)
OUT_DIR  := $(ROOT_DIR)/out
GEN_DIR  := $(OUT_DIR)/gen
LIBS_DIR := $(OUT_DIR)/libs

TARGET   := $(OUT_DIR)/vault_cli
APP_SRC  := vault_cli.c
APP_OBJ  := $(GEN_DIR)/vault_cli.o

MODULES_DIR := $(ROOT_DIR)/../Modules

# Include paths for headers
INCLUDES := -I$(MODULES_DIR)/caesar_cipher/inc -I$(MODULES_DIR)/xor_cipher/inc
CFLAGS   += $(INCLUDES)

# Export environment variables for child Makefiles
export GEN_DIR LIBS_DIR

# Default target
all: build_modules $(TARGET)

# Link executable with Static (.a) and Shared (.so) libraries
$(TARGET): $(APP_OBJ) | $(OUT_DIR)
	@echo "[LINK] Creating executable: $@"
	$(CC) $(APP_OBJ) -L$(LIBS_DIR) -lcaesar_cipher -lxor_cipher -Wl,-rpath,$(LIBS_DIR) -o $@

# Compile Application source file
$(APP_OBJ): $(APP_SRC) | $(GEN_DIR)
	@echo "[CC] Compiling Application source: $<"
	$(CC) $(CFLAGS) -c $< -o $@

# Trigger build for sub-modules
build_modules: | $(GEN_DIR) $(LIBS_DIR)
	@echo "[BUILD] Building Caesar Cipher Module (Static Lib)..."
	$(MAKE) -C $(MODULES_DIR)/caesar_cipher -f caesar_cipher.mk
	@echo "[BUILD] Building XOR Cipher Module (Shared Lib)..."
	$(MAKE) -C $(MODULES_DIR)/xor_cipher -f xor_cipher.mk

# Create output directories if they don't exist
$(OUT_DIR) $(GEN_DIR) $(LIBS_DIR):
	mkdir -p $@

# Clean up build artifacts
clean:
	@echo "[CLEAN] Cleaning Modules..."
	$(MAKE) -C $(MODULES_DIR)/caesar_cipher -f caesar_cipher.mk clean
	$(MAKE) -C $(MODULES_DIR)/xor_cipher -f xor_cipher.mk clean
	@echo "[CLEAN] Removing Application output directory..."
	rm -rf $(OUT_DIR)

.PHONY: all build_modules clean
