# ==============================================================================
# Makefile for XOR Cipher Module (Dynamic Library .so)
# ==============================================================================

CC ?= gcc
CFLAGS ?= -Wall -Wextra -O2 -fPIC -Iinc

SRC_DIR := src
GEN_DIR ?= $(CURDIR)/../../Application/out/gen
LIBS_DIR ?= $(CURDIR)/../../Application/out/libs

SRCS := $(wildcard $(SRC_DIR)/*.c)
OBJS := $(patsubst $(SRC_DIR)/%.c,$(GEN_DIR)/xor_%.o,$(SRCS))

TARGET_LIB := $(LIBS_DIR)/libxor_cipher.so

all: $(TARGET_LIB)

# Create Dynamic Shared Library
$(TARGET_LIB): $(OBJS) | $(LIBS_DIR)
	@echo "[SHARED] Linking Dynamic Library: $@"
	$(CC) -shared -o $@ $(OBJS)

# Compile object files with -fPIC
$(GEN_DIR)/xor_%.o: $(SRC_DIR)/%.c | $(GEN_DIR)
	@echo "[CC] Compiling $< -> $@"
	$(CC) $(CFLAGS) -c $< -o $@

$(GEN_DIR) $(LIBS_DIR):
	mkdir -p $@

clean:
	rm -f $(OBJS) $(TARGET_LIB)

.PHONY: all clean
