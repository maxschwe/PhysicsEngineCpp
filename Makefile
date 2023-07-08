PROJECT_DIRS := ./bin ./doc ./include ./lib ./spike ./src ./test

TARGET_EXEC := output

BUILD_DIR := ./build
SRC_DIRS := ./src

CC = cc
CXX = g++
SRCEXT := cpp

CFLAGS := -Wall
CXXFLAGS := -Wall
LDFLAGS := -lsfml-graphics -lsfml-window -lsfml-system

SHELL = /bin/sh

# The -MMD and -MP flags together generate Makefiles for us!
# These files will have .d instead of .o as the output.
CPPFLAGS += -MMD -MP

# Find all the C and C++ files we want to compile
# Note the single quotes around the * expressions. The shell will incorrectly expand these otherwise, but we want to send the * directly to the find command.

# find all source files
# SRCS := $(shell find $(SRC_DIRS) -name '*.cpp' -or -name '*.c' -or -name '*.s')

# only find source files using the srcext
SRCS := $(shell find $(SRCDIR) -type f -name '*.$(SRCEXT)')

# Prepends BUILD_DIR and appends .o to every src file
# As an example, ./your_dir/hello.cpp turns into ./build/./your_dir/hello.cpp.o
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)

# String substitution (suffix version without %).
# As an example, ./build/hello.cpp.o turns into ./build/hello.cpp.d
DEPS := $(OBJS:.o=.d)

# Every folder in ./src will need to be passed to GCC so that it can find header files
INC_DIRS := $(shell find $(SRC_DIRS) -type d)
# Add a prefix to INC_DIRS. So moduleA would become -ImoduleA. GCC understands this -I flag
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

CPPFLAGS += $(INC_FLAGS)

# initalize used compiler
ifeq ($(SRCEXT), c)
	USED_COMPILER := $(CC)
	BUILD_FLAGS := $(CFLAGS)
else
	USED_COMPILER := $(CXX)
	BUILD_FLAGS := $(CXXFLAGS)
endif

# The final build step.
$(BUILD_DIR)/$(TARGET_EXEC): $(OBJS)
	@echo "Linking..."
	@echo "   $(USED_COMPILER)\t$(OBJS) -o $@ $(LDFLAGS)"; $(USED_COMPILER) $(OBJS) -o $@ $(LDFLAGS)

# Build step for C source
$(BUILD_DIR)/%.c.o: %.c
	@mkdir -p $(dir $@)
	@echo "   $(CC)\t $<"; $(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

# Build step for C++ source
$(BUILD_DIR)/%.cpp.o: %.cpp
	@mkdir -p $(dir $@)
	@echo "   $(CXX)\t$<"; $(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@


clean:
	@echo " Cleaning..."
	rm -r $(BUILD_DIR)

init: 
	mkdir -p $(PROJECT_DIRS)
	touch "README.md"

build: build_start_msg $(BUILD_DIR)/$(TARGET_EXEC)
	@echo "Finished successfully"
	@echo "-------------------------------------------------------"

build_start_msg:
	@echo "Configuration:\n  compiler: \t\t$(USED_COMPILER)\n  preprocessor flags: \t$(CPPFLAGS)\n  build flags: \t\t$(BUILD_FLAGS)\n  linking flags: \t$(LDFLAGS)"
	@echo "Building..."

bar: build
	@$(BUILD_DIR)/$(TARGET_EXEC)
	@echo ""

.PHONY: clean build build_start_msg init

# Include the .d makefiles. The - at the front suppresses the errors of missing
# Makefiles. Initially, all the .d files will be missing, and we don't want those
# errors to show up.
-include $(DEPS)