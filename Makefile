###########################################################################
# Copyright (c) 2018 by Chris Gray, KIFFER Ltd.  All rights reserved.     #
#                                                                         #
# Redistribution and use in source and binary forms, with or without      #
# modification, are permitted provided that the following conditions      #
# are met:                                                                #
# 1. Redistributions of source code must retain the above copyright       #
#    notice, this list of conditions and the following disclaimer.        #
# 2. Redistributions in binary form must reproduce the above copyright    #
#    notice, this list of conditions and the following disclaimer in the  #
#    documentation and/or other materials provided with the distribution. #
# 3. Neither the name of KIFFER Ltd nor the names of other contributors   #
#    may be used to endorse or promote products derived from this         #
#    software without specific prior written permission.                  #
#                                                                         #
# THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED          #
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF    #
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.    #
# IN NO EVENT SHALL KIFFER LTD OR OTHER CONTRIBUTORS BE LIABLE FOR ANY    #
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL      #
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS #
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)   #
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,     #
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING   #
# IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE      #
# POSSIBILITY OF SUCH DAMAGE.                                             #
###########################################################################

CFLAGS = -g
CFLAGS += -Wall -Wsign-compare -Wshadow -Wpointer-arith
CFLAGS += -Wstrict-prototypes -Winline -DDEBUG_LEVEL=7

export MIKA_TOP = $(PWD)

include ./Configuration/platform/$(PLATFORM).mk
include ./Configuration/cpu/$(CPU).mk
include ./Configuration/host/$(HOSTOS).mk
include ./Configuration/mika/default.mk

export VERSION_STRING ?= 1.4.7_TEST
export AWT_DEF ?= none
export CPU
export HOSTOS
export SCHEDULER
export AR

export tooldir = $(MIKA_TOP)/tool
export scriptdir = $(tooldir)/script
export builddir = $(MIKA_TOP)/build/$(PLATFORM)
export libdir = $(builddir)/lib
export objdir = $(builddir)/obj

export awtobjdir = $(objdir)/awt/$(AWT)
export filesystemobjdir = $(objdir)/filesystem/$(FILESYSTEM)
export fpobjdir = $(objdir)/fp/$(FLOATING_POINT)
export mathobjdir = $(objdir)/math/$(MATH)
export networkobjdir = $(objdir)/network/$(NETWORK)

CFLAGS += -I $(MIKA_TOP)/vm-cmp/fp/$(FLOATING_POINT)/include

ifeq "$(AWT)" "rudolph"
  include $(MIKA_TOP)/Configuration/awt/$(AWT_DEF).mk
else ifneq "$(AWT)" "none"
  $(error AWT must be rudolph or none, not $(AWT))
endif

ifdef UNIX
  LIBPREFIX ?= lib
else
  LIBPREFIX ?= ""
endif
export LIBPREFIX

CFLAGS_cpu__arm = -DARM
CFLAGS_cpu__armel = -DARMEL
CFLAGS_cpu__mips = -DMIPS
CFLAGS_cpu__ppc = -DPPC
CFLAGS_cpu__sh4 = -DSH4
CFLAGS_cpu__x86 = -DX86

CFLAGS += $(CFLAGS_cpu__$(CPU))

ifeq ($(CPU),x86)
  LDFLAGS = -m32
endif

ifeq ($(HOSTOS), linux)
  CFLAGS += -DHAVE_TIMEDWAIT
endif

ifeq ($(HOSTOS), android)
  CFLAGS += -DHAVE_TIMEDWAIT
  CFLAGS += --sysroot $(TOOLCHAIN_SYSROOT)
  LDFLAGS += --sysroot $(TOOLCHAIN_SYSROOT)
endif

ifeq ($(HOSTOS), netbsd)
  CFLAGS += -DHAVE_TIMEDWAIT
  LDFLAGS += -m32
endif

#
# Set the compiler for the tools we need. We use the default compiler
# on this compiling host.
#

TOOL_CC   = $(CC)
TOOL_LINK = $(LD)

SCRIPT_DIR = $(MIKA_TOP)/tool/script

#
# The libraries
#

UNICODE_LIB = libunicode
FS_LIB    = libfs
export OSWALD_LIB = $(libdir)/liboswald.a
export AWT_LIB = $(libdir)/libawt.a
export MIKA_LIB = $(libdir)/libmika.a

ifdef UNIX
  BUILD_HOST = `uname`
else
  BUILD_HOST = <unknown>
endif


CFLAGS += -DBOOTCLASSDIR=\"{}/$(BOOTCLASSDIR)\"
CFLAGS += -DBOOTCLASSFILE=\"$(BOOTCLASSFILE)\"
CFLAGS += -DEXTCLASSDIR=\"{}/$(BOOTCLASSDIR)/ext\"
CFLAGS += -DDEFAULT_HEAP_SIZE=\"$(DEFAULT_HEAP_SIZE)\"
CFLAGS += -DDEFAULT_STACK_SIZE=\"$(DEFAULT_STACK_SIZE)\"
CFLAGS += -DVERSION_STRING=\"$(VERSION_STRING)\"

ifeq ($(JAVA5_SUPPORT), true)
  CFLAGS += -DJAVA5
endif

ifeq ($(JDWP), true)
  CFLAGS += -DJDWP
endif

ifeq ($(JAVA_PROFILE), true)
  CFLAGS += -DJAVA_PROFILE
endif

ifeq ($(TRACE_MEM_ALLOC), true)
  CFLAGS += -DTRACE_MEM_ALLOC
endif

ifeq ($(METHOD_DEBUG), true)
  CFLAGS += -DMETHOD_DEBUG
endif

ifdef UNICODE_SUBSETS
  CFLAGS += -DUNICODE_SUBSETS=\"$(UNICODE_SUBSETS)\"
endif

ifeq ($(USE_NATIVE_MALLOC), true)
  CFLAGS += -DUSE_NATIVE_MALLOC
endif

ifeq ($(USE_LIBFFI), true)
  CFLAGS += -DUSE_LIBFFI
endif

ifdef CPU_MIPS
  CFLAGS += -DCPU_MIPS=$(CPU_MIPS)
endif

ifeq ($(USE_NANOSLEEP), true)
  CFLAGS += -DUSE_NANOSLEEP
endif

ifdef HOST_TIMER_GRANULARITY
  CFLAGS += -DHOST_TIMER_GRANULARITY=$(HOST_TIMER_GRANULARITY)
endif

ifeq ($(DETECT_FLYING_PIGS), true)
  CFLAGS += -DDETECT_FLYING_PIGS
endif

ifeq ($(ENABLE_THREAD_RECYCLING), true)
  CFLAGS += -DENABLE_THREAD_RECYCLING
endif

ifeq ($(JAVAX_COMM), true)
  CFLAGS += -DJAVAX_COMM
endif

ifeq ($(MIKA_MAX), true)
  CFLAGS += -DMIKA_MAX
  CFLAGS += -DRESMON
endif

ifeq ($(USE_APP_DIR), true)
  CLASSPATH = "\{\}/apps/"
endif

ifdef CCLASSPATH
  CFLAGS += -DCLASSPATH=\"$(CCLASSPATH)\"
endif

#
# Add the -static flag to the linker if a static binary is required.
#

ifeq ($(STATIC), true)
  LDFLAGS += -static
endif


ifeq ($(BYTECODE_VERIFIER), true)
  CFLAGS += -DUSE_BYTECODE_VERIFIER 
endif

#
# NOTE: The module loader doesn't like gdb symbols.
#
ifndef GDB_SYMBOLS
  GDB_SYMBOLS = false
endif

ifeq ($(DEBUG), true)
  
  CFLAGS += -DDEBUG -DRUNTIME_CHECKS
  
  ifeq ($(HOSTOS), winnt)
    ifeq ($(OPTIM), "-O")
      OPTIM = -O1
    else
      OPTIM = $(OPTIM) -O1
    endif
          #CG optimise for size
    ifeq ($(OPTIM), "-O")
      OPTIM = -Os
    else
      OPTIM = $(OPTIM) -Os
    endif
  endif

  GDB_SYMBOLS = true
  
else  # No debug -> Full optimalisation 
          #CG optimise for size

  ifeq ($(OPTIM), "-O")
    OPTIM = -Os
  else
    OPTIM = $(OPTIM) -Os
  endif

#  CFLAGS += -ggdb
endif

ifeq ($(GDB_SYMBOLS), true)
    CFLAGS += -ggdb  
endif

#
# Only add -fomit-frame-pointer when debugging and profiling are turned off.
# Debugging with the flag on, gives a lot less information. Profiling with the
# flag on is not possible.
#
#
ifeq ($(DEBUG), false)
  ifeq ($(SCHEDULER), oswald)
  CFLAGS += -fomit-frame-pointer
  endif
endif

ifndef UPTIME_LIMIT
  UPTIME_LIMIT = none
endif

ifndef ACADEMIC_LICENCE
  ACADEMIC_LICENCE = false
endif

ifneq ($(UPTIME_LIMIT), none)
  CFLAGS += -DUPTIME_LIMIT=$(UPTIME_LIMIT)
endif 

ifeq ($(ACADEMIC_LICENCE), true)
  CFLAGS += -DACADEMIC_LICENCE
endif 

ifeq ($(AWT_SWAPDISPLAY), true)
  CFLAGS += -DAWT_SWAPDISPLAY
endif
  
CFLAGS_scheduler_oswald = -DOSWALD -D_REENTRANT
CFLAGS_scheduler_o4e = -DO4E -pthread
CFLAGS_scheduler_o4p = -DO4P -D_REENTRANT # -pthread

CFLAGS += $(CFLAGS_scheduler_$(SCHEDULER))
export kernobjdir = $(objdir)/kernel/$(SCHEDULER)

#
# Print out the configuration settings.
#

ifeq "$(AWT)" "rudolph"
  ifeq "$(AWT_DEVICE)" "none"
    CFLAGS += -DAWT_NONE
  else ifeq "$(AWT_DEVICE)" "fdev"
# TODO check that AWT_PIXELFORMAT is one of c332 c555 c565 g4 pp888
# TODO check that AWT_MOUSE is one of touchscreen ps2mouse none
    CFLAGS += -DAWT_FDEV -DAWT_PIXELFORMAT_$(AWT_PIXELFORMAT)
  else ifeq "$(AWT_DEVICE)" "xsim"
    CFLAGS += -DAWT_XSIM
    LDFLAGS += -lX11
  else
    $(error AWT_DEVICE must be fdev, xsim, or none)
  endif
  CFLAGS += -DRUDOLPH 
endif

ifeq "$(FILESYSTEM)" "vfs"
  CFLAGS += -DFSENABLE
else ifeq "$(FILESYSTEM)" "native"
  CFLAGS += -DFSROOT=\"$(FSROOT)\"
else
  $(error FILESYSTEM must be "vfs" or "native")
endif

ifeq "$(FLOATING_POINT)" "native"
  CFLAGS += -DNATIVE_FP
  LDFLAGS += -lm
else ifeq "$(FLOATING_POINT)" "hauser"
  CFLAGS += -DHAUSER_FP
else
  $(error FLOATING_POINT must be "native" or "hauser")
endif

ifeq "$(MATH)" "native"
  CFLAGS += -DNATIVE_MATH
else ifneq "$(MATH)" "java"
  $(error MATH must be "native" or "java")
endif

ifeq "$(NETWORK)" "native"
  export networkinc = $(MIKA_TOP)/vm-cmp/network/native/hal/hostos/$(HOSTOS)/include
else ifeq "$(NETWORK)" "none"
  export networkinc = $(MIKA_TOP)/vm-cmp/network/none/include
else
  $(error NETWORK must be "native" or "none")
endif

ifndef TESTS
  TESTS = false
endif

ifndef JAVAX_COMM
  JAVAX_COMM = false
endif

#
# Compiling for WinNT and Cygwin on an x86 gives errors with leading underscores.
#

ifeq ($(HOSTOS), winnt)
  CFLAGS += -fno-leading-underscore
endif

ifdef CCLASSPATH
  WONKA_INFO += runtime classpath is $(CCLASSPATH);
endif

ifeq ($(FILESYSTEM), vfs)
  WONKA_INFO += using own virtual filesystem\;
  export fsinc = $(MIKA_TOP)/vm-cmp/fs/include
endif
 
ifeq ($(FILESYSTEM), native)
  WONKA_INFO += using host OS filesystem, with virtual root at $(FSROOT)\;
  export fsinc = $(MIKA_TOP)/vm-cmp/fs/$(FILESYSTEM)/hal/hostos/$(HOSTOS)/include
endif

ifeq ($(JAVA5_SUPPORT), true)
  WONKA_INFO += with Java5 support\;
endif

ifeq ($(JAVA5_SUPPORT), false )
  WONKA_INFO += no Java5 support\;
endif

ifeq ($(JDWP), true)
  WONKA_INFO += with JDWP enabled\;
endif

ifeq ($(JDWP), false)
  WONKA_INFO += no JDWP\;
endif

ifeq ($(USE_LIBFFI), true)
  WONKA_INFO += using libffi to call native code\;
endif

ifeq ($(USE_LIBFFI), false)
  WONKA_INFO += using own hacks to call native code\;
endif


ifeq ($(BYTECODE_VERIFIER), true )
  WONKA_INFO += bytecode verification is enabled\;
endif

ifeq ($(BYTECODE_VERIFIER), false)
  WONKA_INFO += bytecode verification is disabled\;
endif

ifeq ($(NETWORK), none )
  WONKA_INFO += no network\;
#  export networkinc = $(MIKA_TOP)/vm-cmp/network/none/include
endif

ifeq ($(NETWORK), native)
  WONKA_INFO += using the host OS network facilities\;
#  export networkinc = $(MIKA_TOP)/vm-cmp/network/native/hal/hostos/$(HOSTOS)/include
endif

ifeq ($(SECURITY), fine)
#    ECHO "Warning: SECURITY=fine is deprecated, using SECURITY=java2"
    SECURITY = java2
endif
ifeq ($(SECURITY), coarse)
#    ECHO "Warning: SECURITY=coarse is deprecated, using SECURITY=java2";
    SECURITY = java2
endif

ifeq ($(SECURITY), java2)
    WONKA_INFO += fine-grained (Java2) security\;
endif
ifeq ($(SECURITY), none)
    WONKA_INFO += no security\;
endif

ifeq ($(FLOATING_POINT), native)
  WONKA_INFO += using native floating-point\;
endif

ifeq ($(FLOATING_POINT), hauser)
  WONKA_INFO += using own floating-point after John Hauser\;
endif

ifeq ($(MATH), native)
  WONKA_INFO += using native math functions\;
endif

ifeq ($(MATH), java)
  WONKA_INFO += using all-java math functions\;
endif


ifeq ($(UNICODE_SUBSETS), 0)
  WONKA_INFO += minimal Unicode support\;
else
  ifeq ($(UNICODE_SUBSETS), 999 )
    WONKA_INFO += full Unicode support\;
  else
    WONKA_INFO += support for Unicode subsets $(UNICODE_SUBSETS)\;
  endif
endif

WONKA_INFO += using own routines for unzipping\;

ifeq ($(ENABLE_THREAD_RECYCLING), true )
  WONKA_INFO += with recycling of native threads\;
else
  WONKA_INFO += no recycling of native threads\;
endif

ifeq ($(JAVAX_COMM), true )
    WONKA_INFO += with javax.comm\;
endif

ifeq ($(JAVAX_COMM), false)
    WONKA_INFO += no javax.comm\;
endif

ifeq ($(TESTS), true )
  TEST_INFO = generating tests for Mauve and for the VisualTestEngine.
endif
ifeq ($(TESTS), false)
  TEST_INFO = not generating tests for Mauve and for the VisualTestEngine.
endif

ifneq ($(UPTIME_LIMIT), none)
  WONKA_INFO += will exit automatically after $(UPTIME_LIMIT) seconds\;
endif

ifeq "$(AWT)" "rudolph"
    AWT_INFO = Rudolph AWT\;

    ifeq "$(AWT_DEVICE)" "none"
        AWT_INFO += no visual display\;
    endif
    ifeq "$(AWT_DEVICE)" "fdev"
        AWT_INFO += frame buffer display\;
    endif
    ifeq "$(AWT_DEVICE)" "xsim"
        AWT_INFO += display is X window\;
    endif

    ifeq "$(AWT_GIF_SUPPORT)" "true"
      AWT_INFO += GIF support enabled\;
    endif

    ifeq "$(AWT_JPEG_SUPPORT)" "true"
      AWT_INFO += JPEG support enabled\;
    endif
endif

ifeq ($(AWT), none )
    AWT_INFO = no AWT\;
endif

ifeq ($(SCHEDULER), o4p)
  ifeq ($(USE_NANOSLEEP), true)
    O4P_INFO = using nanosleep(2) for internal timing loop\;
  else
    O4P_INFO = using usleep(3) for internal timing loop\;
  endif

  ifeq ($(HAVE_TIMEDWAIT), true)
    O4P_INFO += using pthread_cond_timedwait\;
  else
    O4P_INFO += not using pthread_cond_timedwait\;
  endif

  ifeq ($(USE_NATIVE_MALLOC), true)
    O4P_INFO += using native malloc\;
  else
    O4P_INFO += using own memory management routines\;
  endif

  ifdef HOST_TIMER_GRANULARITY
    O4P_INFO += host timer granularity = $(HOST_TIMER_GRANULARITY) usec\;
  endif
else
  ifdef CPU_MIPS
    OSWALD_INFO += estimated CPU speed = $(CPU_MIPS) MIPS\;
  endif

  ifdef HOST_TIMER_GRANULARITY
    OSWALD_INFO += host timer granularity = $(HOST_TIMER_GRANULARITY) usec\;
  endif

  ifeq ($(SHARED_HEAP), true)
    OSWALD_INFO += exporting own version of malloc and friends\;
  endif

endif

CFLAGS += -DWONKA_INFO=\"" $(WONKA_INFO) "\"
CFLAGS += -DTEST_INFO=\"" $(TEST_INFO) "\"
CFLAGS += -DAWT_INFO=\"" $(AWT_INFO) "\"
ifeq ($(SCHEDULER), o4p)
  CFLAGS += -DO4P_INFO=\"" $(O4P_INFO) "\"
endif

ifeq ($(SCHEDULER), oswald)
  CFLAGS += -DOSWALD_INFO=\"" $(OSWALD_INFO) "\"
endif

export gendir = $(builddir)/generated

CFLAGS += -DBUILD_HOST=\"" $(BUILD_HOST) "\"

# TODO objdirlist not used anywhere?
objdirlist += $(objdir)/awt/$(AWT)
objdirlist += $(objdir)/filesystem/$(FILESYSTEM)
objdirlist += $(objdir)/fp/$(FLOATING_POINT)
objdirlist += $(objdir)/math/$(MATH)
objdirlist += $(objdir)/network/$(NETWORK)

export CFLAGS
export LDFLAGS

.PHONY : mika core-vm echo builddir install clean test common-test scheduler-test

mika : echo builddir kernel core-vm

echo :
	@echo "Building Mika for platform '$(PLATFORM)'"
	@echo "CPU =" $(CPU)
	@echo "HOSTOS =" $(HOSTOS)
	@echo "SCHEDULER =" $(SCHEDULER)
	@echo "AWT =" $(AWT)
	@echo "CFLAGS =" $(CFLAGS)
	@echo "LDFLAGS =" $(LDFLAGS)
	@echo "SHARED_OBJECTS =" $(SHARED_OBJECTS)

builddir :
	@echo "Creating " $(objdir)
	@mkdir -p $(objdir)
	@echo "Creating " awtobjdir
	@mkdir -p $(awtobjdir)
	@echo "Creating " filesystemobjdir
	@mkdir -p $(filesystemobjdir)
	@echo "Creating " fpobjdir
	@mkdir -p $(fpobjdir)
	@echo "Creating " mathobjdir
	@mkdir -p $(mathobjdir)
	@echo "Creating " networkobjdir
	@mkdir -p $(networkobjdir)
	@echo "Creating " generatedobjdir
	@mkdir -p $(objdir)/generated
	@echo "Creating " $(libdir)
	@mkdir -p $(libdir)
	@echo "Creating " $(gendir)
	@mkdir -p $(gendir)

kernel : kcommon 
	make -C vm-cmp/kernel/$(SCHEDULER) 

kcommon :
	make -C vm-cmp/kernel/common 

comm :
ifeq ($(JAVAX_COMM), true)
	make -C vm-ext/comm 
endif

max :
ifeq ($(MIKA_MAX), true)
	make -C max/src/native/mika/max 
endif

core-vm : comm max 
	make -C core-vm 

install : mika
	@echo "Installing mika binary in ${INSTALL_DIR}"
	cp core-vm/mika ${INSTALL_DIR}

clean :
	@rm -rf $(gendir)
	@rm -rf $(objdir)
	@rm -rf $(libdir)
	-make -C vm-cmp/kernel/$(SCHEDULER) clean
	-make -C vm-cmp/kernel/common clean
	-make -C vm-cmp/fs/$(FILESYSTEM) clean
	-make -C vm-cmp/network/$(NETWORK) clean
	-make -C vm-cmp/awt/$(AWT) clean
	-make -C tool clean
	-make -C vm-ext/jpda clean
	-make -C vm-cmp/fp/$(FLOATING_POINT) clean
	-make -C vm-cmp/security/provider/any/src/native/wonka/security clean
	-make -C vm-cmp/math/$(MATH) clean
	-make -C vm-ext/comm clean
	-make -C core-vm/adt clean
	-make -C max/src/native/mika/max clean

test : scheduler-test

scheduler-test : common-test
	make -C vm-cmp/kernel/$(SCHEDULER) test

common-test :
	make -C vm-cmp/kernel/common test

#	make -C vm-cmp/fs/$(FILESYSTEM) test
#	make -C vm-cmp/network/$(NETWORK) test
#	make -C vm-cmp/awt/$(AWT) test
#	make -C tool test
#	make -C vm-ext/jpda test
#	make -C vm-cmp/fp/$(FLOATING_POINT) test
#	make -C vm-cmp/security/provider/any/src/native/wonka/security test
#	make -C vm-cmp/math/$(MATH) test
#	make -C vm-ext/comm test
#	make -C max/src/native/mika/max test


