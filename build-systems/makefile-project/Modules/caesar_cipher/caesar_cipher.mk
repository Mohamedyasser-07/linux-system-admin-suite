# ==============================================================================
# Makefile for Caesar Cipher Module (Static Library .a)
# ==============================================================================

CC ?= gcc
CFLAGS ?= -Wall -Wextra -O2 -Iinc

SRC_DIR := src
GEN_DIR ?= $(CURDIR)/../../Application/out/gen
LIBS_DIR ?= $(CURDIR)/../../Application/out/libs

SRCS := $(wildcard $(SRC_DIR)/*.c)
OBJS := $(patsubst $(SRC_DIR)/%.c,$(GEN_DIR)/caesar_%.o,$(SRCS))

TARGET_LIB := $(LIBS_DIR)/libcaesar_cipher.a

all: $(TARGET_LIB)

# Create Static Library archive
$(TARGET_LIB): $(OBJS) | $(LIBS_DIR)
	@echo "[AR] Archiving Static Library: $@"
	ar rcs $@ $(OBJS)

# Compile object files
$(GEN_DIR)/caesar_%.o: $(SRC_DIR)/%.c | $(GEN_DIR)
	@echo "[CC] Compiling $< -> $@"
	$(CC) $(CFLAGS) -c $< -o $@

$(GEN_DIR) $(LIBS_DIR):
	mkdir -p $@

clean:
	rm -f $(OBJS) $(TARGET_LIB)

.PHONY: all clean
