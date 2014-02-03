# This "platform" file is intended for building compiler-rt using gcc.
# The actual target platform is selected by setting the TargetTriple variable to the corresponding LLVM triple.

Description := Static runtime libraries for platforms selected by 'TargetTriple'

# Provide defaults for the required vars
ifndef CC
	CC := gcc
endif
ifndef CFLAGS
	CFLAGS := -Wall -O3
endif

Configs := builtins

Arch := $(word 1,$(subst -, ,$(TargetTriple)))
ifeq ($(Arch),i686)
	Arch := i386
else ifeq ($(Arch),arm)
	Arch := armv7
endif

# Filter out stuff that gcc cannot compile (these are only needed for clang-generated code anywasys).
CommonFunctions_gcc := $(filter-out atomic enable_execute_stack,$(CommonFunctions))

FUNCTIONS.builtins := $(CommonFunctions_gcc) $(value ArchFunctions.$(Arch))

