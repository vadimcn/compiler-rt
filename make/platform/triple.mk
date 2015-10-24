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

ifneq (,$(findstring windows,$(TargetTriple)))
	# Suppress annoying warning that basically says "-fPIC is ignored on Windows because all code is PIC"
	override CFLAGS := $(CFLAGS) -fno-PIC
endif

# Otherwise compilation fails on warnings about conflicting types some GCC built-in functions
# __divdc3, __divsc3, __divxc3 and others.  We don't care because we are building runtime for LLVM.
override CFLAGS := $(CFLAGS) -Wno-error

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

BuildFunctions := $(CommonFunctions) $(value ArchFunctions.$(Arch))

# Filter out stuff that gcc cannot compile (these are only needed for clang-generated code anywasys).
BuildFunctions := $(filter-out atomic%,$(BuildFunctions))

# Filter out stuff which is not available on specific target
# For example, sync_fetch_and_add_4 uses Thumb instructions, which are unavailable
# when building for arm-linux-androideabi
ifeq ($(TargetTriple),arm-linux-androideabi)
    Remove := \
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
    BuildFunctions := $(filter-out $(Remove),$(BuildFunctions))
endif

# Clear cache is builtin on aarch64-apple-ios
# arm64 and aarch64 are synonims, but iOS targets usually use arm64 (history reasons)
ifeq (aarch64-apple-ios,$(subst arm64,aarch64,$(TargetTriple)))
	BuildFunctions := $(filter-out clear_cache,$(BuildFunctions))
endif

FUNCTIONS.builtins := $(BuildFunctions)
