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
ifneq (,$(findstring ios,$(TargetTriple)))
	Arch := armv7
else ifneq (,$(findstring android,$(TargetTriple)))
	Arch := armv7
endif
endif

# Filter out stuff that gcc cannot compile (these are only needed for clang-generated code anywasys).
CommonFunctions_gcc := $(filter-out atomic enable_execute_stack,$(CommonFunctions))

# Filter out stuff which is not available on specific target
# For example, sync_fetch_and_add_4 uses Thumb instructions, which are unavailable
# when building for arm-linux-androideabi
ifeq ($(TargetTriple),arm-linux-androideabi)
    ArchDisabledFunctions := \
                sync_fetch_and_add_4 \
                sync_fetch_and_sub_4 \
                sync_fetch_and_and_4 \
                sync_fetch_and_or_4 \
                sync_fetch_and_xor_4 \
                sync_fetch_and_nand_4 \
                sync_fetch_and_max_4 \
                sync_fetch_and_umax_4 \
                sync_fetch_and_min_4 \
                sync_fetch_and_umin_4 \
                sync_fetch_and_add_8 \
                sync_fetch_and_sub_8 \
                sync_fetch_and_and_8 \
                sync_fetch_and_or_8 \
                sync_fetch_and_xor_8 \
                sync_fetch_and_nand_8 \
                sync_fetch_and_max_8 \
                sync_fetch_and_umax_8 \
                sync_fetch_and_min_8 \
                sync_fetch_and_umin_8
endif

ArchEnabledFunctions := $(filter-out $(ArchDisabledFunctions),$(value ArchFunctions.$(Arch)))

FUNCTIONS.builtins := $(CommonFunctions_gcc) $(ArchEnabledFunctions)

