Description := Static runtime libraries for compilers (multiple architectures)

CC := gcc

# Provide defaults in case caller did not define CFLAGS for us
ifndef CFLAGS
CFLAGS := -Wall -m32 -O3
endif

Configs := i686-pc-mingw32

Arch := unknown
Arch.i686-pc-mingw32 := i386

# Filter out stuff that gcc cannot compile (these are only needed for clang-generated code anywasys).
CommonFunctions_gcc := $(filter-out atomic enable_execute_stack,$(CommonFunctions))

FUNCTIONS.i686-pc-mingw32 = $(CommonFunctions_gcc) $(ArchFunctions.i386)
	#$(AsanFunctions) $(InterceptionFunctions) $(SanitizerCommonFunctions)
