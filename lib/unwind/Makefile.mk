#===- lib/unwind/Makefile.mk -------------------------------*- Makefile -*--===#
#
#                     The LLVM Compiler Infrastructure
#
# This file is distributed under the University of Illinois Open Source
# License. See LICENSE.TXT for details.
#
#===------------------------------------------------------------------------===#

ModuleName := unwind
SubDirs :=

AsmSources := $(foreach file,$(wildcard $(Dir)/*.S),$(notdir $(file)))
Sources := $(foreach file,$(wildcard $(Dir)/*.cpp),$(notdir $(file))) \
           $(foreach file,$(wildcard $(Dir)/*.c),$(notdir $(file)))
ObjNames := $(Sources:%.cpp=%.o)
ObjNames := $(ObjNames:%.c=%.o) $(AsmSources:%.S=%.o)

Implementation := Generic

Dependencies := $(wildcard $(Dir)/*.h*)

UnwindFunctions := $(ObjNames:%.o=%)

$(info AsmSources=$(AsmSources))
$(info Sources=$(Sources))
$(info ObjNames=$(ObjNames))
$(info UnwindFunctions=$(UnwindFunctions))
