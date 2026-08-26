# ==============================================================================
# Makefile for C Process Monitor (Task Manager)
# ==============================================================================

CC      ?= gcc
CFLAGS  ?= -Wall -Wextra -Wpedantic -O2
LDFLAGS ?=

SRC_DIR := src
OUT_DIR := out

TARGET := $(OUT_DIR)/task_manager
SRC    := $(SRC_DIR)/taskmanager.c

# Sanity-check the required runtime tools so the user gets a clear
# warning instead of a silent "no output". We capture `command -v`
# for each tool with a single shell invocation so the Makefile
# grammar stays well-formed (no $(info) inside $(foreach) tricks).
REQUIRED_CMDS := mpstat ps
HAVE_MPSTAT := $(shell command -v mpstat >/dev/null 2>&1 && echo y)
HAVE_PS     := $(shell command -v ps     >/dev/null 2>&1 && echo y)
ifeq ($(HAVE_MPSTAT),)
$(warning [WARN] 'mpstat' not found in PATH — task_manager will fail at runtime. Install with: sudo apt-get install sysstat)
endif
ifeq ($(HAVE_PS),)
$(warning [WARN] 'ps' not found in PATH — task_manager will fail at runtime. Install with: sudo apt-get install procps)
endif

all: $(TARGET)

$(TARGET): $(SRC) | $(OUT_DIR)
	@echo "[CC] Compiling System Task Manager..."
	$(CC) $(CFLAGS) $(SRC) -o $@ $(LDFLAGS)
	@echo "[SUCCESS] Executable generated at $@"

$(OUT_DIR):
	mkdir -p $@

clean:
	@echo "[CLEAN] Removing Task Manager build files..."
	rm -rf $(OUT_DIR)

.PHONY: all clean
