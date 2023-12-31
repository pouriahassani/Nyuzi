# CMake build for CompilerRT.
#
# An important constraint of the build is that it only produces libraries
# based on the ability of the host toolchain to target various platforms.

cmake_minimum_required(VERSION 3.4.3)

# Check if compiler-rt is built as a standalone project.
if (CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR OR COMPILER_RT_STANDALONE_BUILD)
  project(CompilerRT C CXX ASM)
  set(COMPILER_RT_STANDALONE_BUILD TRUE)
  set_property(GLOBAL PROPERTY USE_FOLDERS ON)
endif()

# Add path for custom compiler-rt modules.
list(INSERT CMAKE_MODULE_PATH 0
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake"
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules"
  )

if(CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_CFG_RESOLVED_INTDIR "${CMAKE_CFG_INTDIR}/")
else()
  set(CMAKE_CFG_RESOLVED_INTDIR "")
endif()

include(base-config-ix)
include(CompilerRTUtils)

option(COMPILER_RT_BUILD_BUILTINS "Build builtins" OFF)
mark_as_advanced(COMPILER_RT_BUILD_BUILTINS)
option(COMPILER_RT_BUILD_SANITIZERS "Build sanitizers" OFF)
mark_as_advanced(COMPILER_RT_BUILD_SANITIZERS)
option(COMPILER_RT_BUILD_XRAY "Build xray" OFF)
mark_as_advanced(COMPILER_RT_BUILD_XRAY)
option(COMPILER_RT_BUILD_LIBFUZZER "Build libFuzzer" OFF)
mark_as_advanced(COMPILER_RT_BUILD_LIBFUZZER)
option(COMPILER_RT_BUILD_PROFILE "Build profile runtime" OFF)
mark_as_advanced(COMPILER_RT_BUILD_PROFILE)
option(COMPILER_RT_BUILD_XRAY_NO_PREINIT "Build xray with no preinit patching" OFF)
mark_as_advanced(COMPILER_RT_BUILD_XRAY_NO_PREINIT)

set(COMPILER_RT_ASAN_SHADOW_SCALE ""
    CACHE STRING "Override the shadow scale to be used in ASan runtime")

if (NOT COMPILER_RT_ASAN_SHADOW_SCALE STREQUAL "")
  # Check that the shadow scale value is valid.
  if (NOT (COMPILER_RT_ASAN_SHADOW_SCALE GREATER -1 AND
           COMPILER_RT_ASAN_SHADOW_SCALE LESS 8))
    message(FATAL_ERROR "
      Invalid ASan Shadow Scale '${COMPILER_RT_ASAN_SHADOW_SCALE}'.")
  endif()

  set(COMPILER_RT_ASAN_SHADOW_SCALE_LLVM_FLAG
      -mllvm -asan-mapping-scale=${COMPILER_RT_ASAN_SHADOW_SCALE})
  set(COMPILER_RT_ASAN_SHADOW_SCALE_DEFINITION
      ASAN_SHADOW_SCALE=${COMPILER_RT_ASAN_SHADOW_SCALE})
  set(COMPILER_RT_ASAN_SHADOW_SCALE_FLAG
      -D${COMPILER_RT_ASAN_SHADOW_SCALE_DEFINITION})
endif()

set(COMPILER_RT_HWASAN_WITH_INTERCEPTORS ON CACHE BOOLEAN
    "Enable libc interceptors in HWASan (testing mode)")

set(COMPILER_RT_BAREMETAL_BUILD OFF CACHE BOOLEAN
  "Build for a bare-metal target.")

if (COMPILER_RT_STANDALONE_BUILD)
  load_llvm_config()
  if (TARGET intrinsics_gen)
    # Loading the llvm config causes this target to be imported so place it
    # under the appropriate folder in an IDE.
    set_target_properties(intrinsics_gen PROPERTIES FOLDER "Compiler-RT Misc")
  endif()

  # Find Python interpreter.
  set(Python_ADDITIONAL_VERSIONS 2.7 2.6 2.5)
  include(FindPythonInterp)
  if(NOT PYTHONINTERP_FOUND)
    message(FATAL_ERROR "
      Unable to find Python interpreter required testing. Please install Python
      or specify the PYTHON_EXECUTABLE CMake variable.")
  endif()

  # Ensure that fat libraries are built correctly on Darwin
  if(CMAKE_SYSTEM_NAME STREQUAL Darwin)
    if(NOT CMAKE_LIBTOOL)
      find_program(CMAKE_XCRUN
                   NAMES
                     xcrun)
      if(CMAKE_XCRUN)
        execute_process(COMMAND
                          ${CMAKE_XCRUN} -find libtool
                        OUTPUT_VARIABLE
                          CMAKE_LIBTOOL
                        OUTPUT_STRIP_TRAILING_WHITESPACE)
      endif()

      if(NOT CMAKE_LIBTOOL OR NOT EXISTS CMAKE_LIBTOOL)
        find_program(CMAKE_LIBTOOL
                     NAMES
                       libtool)
      endif()
    endif()

    get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)

    if(CMAKE_LIBTOOL)
      set(CMAKE_LIBTOOL ${CMAKE_LIBTOOL} CACHE PATH "libtool executable")
      message(STATUS "Found libtool - ${CMAKE_LIBTOOL}")

      execute_process(COMMAND
                        ${CMAKE_LIBTOOL} -V
                      OUTPUT_VARIABLE
                        LIBTOOL_V_OUTPUT
                      OUTPUT_STRIP_TRAILING_WHITESPACE)
      if("${LIBTOOL_V_OUTPUT}" MATCHES ".*cctools-([0-9]+).*")
        string(REGEX REPLACE ".*cctools-([0-9]+).*" "\\1" LIBTOOL_VERSION ${LIBTOOL_V_OUTPUT})
        if(NOT LIBTOOL_VERSION VERSION_LESS "862")
          set(LIBTOOL_NO_WARNING_FLAG "-no_warning_for_no_symbols")
        endif()
      endif()

      foreach(lang ${languages})
        set(CMAKE_${lang}_CREATE_STATIC_LIBRARY "\"${CMAKE_LIBTOOL}\" -static ${LIBTOOL_NO_WARNING_FLAG} -o <TARGET> <LINK_FLAGS> <OBJECTS>")
      endforeach()
    endif()

    # Workaround SIP :-(
    if(DYLD_LIBRARY_PATH)
      set(dyld_envar "DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH}")
      foreach(lang ${languages})
        foreach(cmd ${CMAKE_${lang}_CREATE_STATIC_LIBRARY})
          list(APPEND CMAKE_${lang}_CREATE_STATIC_LIBRARY_NEW "${dyld_envar} ${cmd}")
        endforeach()
      endforeach()
    endif()
  endif()

  # Define default arguments to lit.
  set(LIT_ARGS_DEFAULT "-sv")
  if (MSVC OR XCODE)
    set(LIT_ARGS_DEFAULT "${LIT_ARGS_DEFAULT} --no-progress-bar")
  endif()
  set(LLVM_LIT_ARGS "${LIT_ARGS_DEFAULT}" CACHE STRING "Default options for lit")
  set(LLVM_LIT_OUTPUT_DIR "${COMPILER_RT_EXEC_OUTPUT_DIR}")
endif()

construct_compiler_rt_default_triple()
if ("${COMPILER_RT_DEFAULT_TARGET_TRIPLE}" MATCHES ".*hf$")
  if (${COMPILER_RT_DEFAULT_TARGET_ARCH} MATCHES "^arm")
    set(COMPILER_RT_DEFAULT_TARGET_ARCH "armhf")
  endif()
endif()
if ("${COMPILER_RT_DEFAULT_TARGET_TRIPLE}" MATCHES ".*android.*")
  set(ANDROID 1)
endif()
pythonize_bool(ANDROID)

set(ANDROID_NDK_VERSION 18
    CACHE STRING "Set this to the Android NDK version that you are using")

set(COMPILER_RT_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set(COMPILER_RT_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR})

pythonize_bool(LLVM_ENABLE_PER_TARGET_RUNTIME_DIR)

# We support running instrumented tests when we're not cross compiling
# and target a UNIX-like system or Windows.
# We can run tests on Android even when we are cross-compiling.
if(("${CMAKE_HOST_SYSTEM}" STREQUAL "${CMAKE_SYSTEM}" AND (UNIX OR WIN32)) OR ANDROID
   OR COMPILER_RT_EMULATOR)
  option(COMPILER_RT_CAN_EXECUTE_TESTS "Can we execute instrumented tests" ON)
else()
  option(COMPILER_RT_CAN_EXECUTE_TESTS "Can we execute instrumented tests" OFF)
endif()

option(COMPILER_RT_DEBUG "Build runtimes with full debug info" OFF)
option(COMPILER_RT_EXTERNALIZE_DEBUGINFO
  "Generate dSYM files and strip executables and libraries (Darwin Only)" OFF)
# COMPILER_RT_DEBUG_PYBOOL is used by lit.common.configured.in.
pythonize_bool(COMPILER_RT_DEBUG)

option(COMPILER_RT_INTERCEPT_LIBDISPATCH
  "Support interception of libdispatch (GCD). Requires '-fblocks'" OFF)
option(COMPILER_RT_BLOCKS_RUNTIME_LIBRARY_PATH
  "Library search path for blocks runtime (-lBlocksRuntime)" "")
option(COMPILER_RT_LIBDISPATCH_LIBRARY_PATH
  "Library search path for libdispatch (-ldispatch)" "")
if (COMPILER_RT_INTERCEPT_LIBDISPATCH)
  set(COMPILER_RT_INTERCEPT_LIBDISPATCH_CFLAGS -fblocks)
  set(COMPILER_RT_INTERCEPT_LIBDISPATCH_LINK_FLAGS)
  if (COMPILER_RT_BLOCKS_RUNTIME_LIBRARY_PATH)
    list(APPEND COMPILER_RT_INTERCEPT_LIBDISPATCH_LINK_FLAGS
        -L${COMPILER_RT_BLOCKS_RUNTIME_LIBRARY_PATH}
        -Wl,-rpath=${COMPILER_RT_BLOCKS_RUNTIME_LIBRARY_PATH})
  endif()
  if (COMPILER_RT_LIBDISPATCH_LIBRARY_PATH)
    list(APPEND COMPILER_RT_INTERCEPT_LIBDISPATCH_LINK_FLAGS
        -L${COMPILER_RT_LIBDISPATCH_LIBRARY_PATH}
        -Wl,-rpath=${COMPILER_RT_LIBDISPATCH_LIBRARY_PATH})
  endif()
  list(APPEND COMPILER_RT_INTERCEPT_LIBDISPATCH_LINK_FLAGS -lBlocksRuntime -ldispatch)
endif()
if (APPLE AND XXX_DISABLE_NYUZI) # Always enable on Apple platforms.
  set(COMPILER_RT_INTERCEPT_LIBDISPATCH ON)
endif()
pythonize_bool(COMPILER_RT_INTERCEPT_LIBDISPATCH)

if(APPLE AND XXX_DISABLE_NYUZI AND SANITIZER_MIN_OSX_VERSION AND SANITIZER_MIN_OSX_VERSION VERSION_LESS "10.9")
  # Mac OS X prior to 10.9 had problems with exporting symbols from
  # libc++/libc++abi.
  set(cxxabi_supported OFF)
else()
  set(cxxabi_supported ON)
endif()

option(SANITIZER_ALLOW_CXXABI "Allow use of C++ ABI details in ubsan" ON)

set(SANITIZE_CAN_USE_CXXABI OFF)
if (cxxabi_supported AND SANITIZER_ALLOW_CXXABI)
  set(SANITIZER_CAN_USE_CXXABI ON)
endif()
pythonize_bool(SANITIZER_CAN_USE_CXXABI)

macro(handle_default_cxx_lib var)
  if (${var} STREQUAL "default")
    if (APPLE OR CMAKE_SYSTEM_NAME MATCHES "FreeBSD")
      set(${var}_LIBNAME "libc++")
      set(${var}_SYSTEM 1)
    elseif (FUCHSIA)
      set(${var}_LIBNAME "libc++")
      set(${var}_INTREE 1)
    else()
      set(${var}_LIBNAME "libstdc++")
      set(${var}_SYSTEM 1)
    endif()
  else()
    set(${var}_LIBNAME "${${var}}")
    set(${var}_SYSTEM 1)
  endif()
endmacro()

# This is either directly the C++ ABI library or the full C++ library
# which pulls in the ABI transitively.
set(SANITIZER_CXX_ABI "default" CACHE STRING
    "Specify C++ ABI library to use.")
set(CXXABIS none default libstdc++ libc++ libcxxabi)
set_property(CACHE SANITIZER_CXX_ABI PROPERTY STRINGS ;${CXXABIS})
handle_default_cxx_lib(SANITIZER_CXX_ABI)

# This needs to be a full C++ library for linking gtest and unit tests.
set(SANITIZER_TEST_CXX "default" CACHE STRING
    "Specify C++ library to use for tests.")
set(CXXLIBS none default libstdc++ libc++)
set_property(CACHE SANITIZER_TEST_CXX PROPERTY STRINGS ;${CXXLIBS})
handle_default_cxx_lib(SANITIZER_TEST_CXX)

set(DEFAULT_SANITIZER_USE_STATIC_LLVM_UNWINDER OFF)
if (FUCHSIA)
  set(DEFAULT_SANITIZER_USE_STATIC_LLVM_UNWINDER ON)
elseif (DEFINED LIBUNWIND_ENABLE_SHARED AND NOT LIBUNWIND_ENABLE_SHARED)
  set(DEFAULT_SANITIZER_USE_STATIC_LLVM_UNWINDER ON)
endif()

option(SANITIZER_USE_STATIC_LLVM_UNWINDER
  "Use static LLVM unwinder." ${DEFAULT_SANITIZER_USE_STATIC_LLVM_UNWINDER})

set(DEFAULT_SANITIZER_USE_STATIC_CXX_ABI OFF)
if (DEFINED LIBCXXABI_ENABLE_SHARED AND NOT LIBCXXABI_ENABLE_SHARED)
  set(DEFAULT_SANITIZER_USE_STATIC_CXX_ABI ON)
endif()

option(SANITIZER_USE_STATIC_CXX_ABI
  "Use static libc++abi." ${DEFAULT_SANITIZER_USE_STATIC_CXX_ABI})

set(DEFAULT_COMPILER_RT_USE_BUILTINS_LIBRARY OFF)
if (FUCHSIA)
  set(DEFAULT_COMPILER_RT_USE_BUILTINS_LIBRARY ON)
endif()

option(COMPILER_RT_USE_BUILTINS_LIBRARY
  "Use compiler-rt builtins instead of libgcc" ${DEFAULT_COMPILER_RT_USE_BUILTINS_LIBRARY})

include(config-ix)

#================================
# Setup Compiler Flags
#================================

if(MSVC)
  # Override any existing /W flags with /W4. This is what LLVM does.  Failing to
  # remove other /W[0-4] flags will result in a warning about overriding a
  # previous flag.
  if (COMPILER_RT_HAS_W4_FLAG)
    string(REGEX REPLACE " /W[0-4]" "" CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")
    string(REGEX REPLACE " /W[0-4]" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
    append_string_if(COMPILER_RT_HAS_W4_FLAG /W4 CMAKE_C_FLAGS CMAKE_CXX_FLAGS)
  endif()
else()
  append_string_if(COMPILER_RT_HAS_WALL_FLAG -Wall CMAKE_C_FLAGS CMAKE_CXX_FLAGS)
endif()
if(COMPILER_RT_ENABLE_WERROR)
  append_string_if(COMPILER_RT_HAS_WERROR_FLAG -Werror CMAKE_C_FLAGS CMAKE_CXX_FLAGS)
  append_string_if(COMPILER_RT_HAS_WX_FLAG /WX CMAKE_C_FLAGS CMAKE_CXX_FLAGS)
endif()

append_string_if(COMPILER_RT_HAS_STD_CXX11_FLAG -std=c++11 CMAKE_CXX_FLAGS)

# Emulate C99 and C++11's __func__ for MSVC prior to 2013 CTP.
if(NOT COMPILER_RT_HAS_FUNC_SYMBOL)
  add_definitions(-D__func__=__FUNCTION__)
endif()

# Provide some common commmandline flags for Sanitizer runtimes.
if(NOT WIN32)
  append_list_if(COMPILER_RT_HAS_FPIC_FLAG -fPIC SANITIZER_COMMON_CFLAGS)
endif()
append_list_if(COMPILER_RT_HAS_FNO_BUILTIN_FLAG -fno-builtin SANITIZER_COMMON_CFLAGS)
append_list_if(COMPILER_RT_HAS_FNO_EXCEPTIONS_FLAG -fno-exceptions SANITIZER_COMMON_CFLAGS)
if(NOT COMPILER_RT_DEBUG AND NOT (APPLE AND XXX_DISABLE_NYUZI))
  append_list_if(COMPILER_RT_HAS_FOMIT_FRAME_POINTER_FLAG -fomit-frame-pointer SANITIZER_COMMON_CFLAGS)
endif()
append_list_if(COMPILER_RT_HAS_FUNWIND_TABLES_FLAG -funwind-tables SANITIZER_COMMON_CFLAGS)
append_list_if(COMPILER_RT_HAS_FNO_STACK_PROTECTOR_FLAG -fno-stack-protector SANITIZER_COMMON_CFLAGS)
append_list_if(COMPILER_RT_HAS_FNO_SANITIZE_SAFE_STACK_FLAG -fno-sanitize=safe-stack SANITIZER_COMMON_CFLAGS)
append_list_if(COMPILER_RT_HAS_FVISIBILITY_HIDDEN_FLAG -fvisibility=hidden SANITIZER_COMMON_CFLAGS)
if(NOT COMPILER_RT_HAS_FVISIBILITY_HIDDEN_FLAG)
  append_list_if(COMPILER_RT_HAS_FVISIBILITY_INLINES_HIDDEN_FLAG -fvisibility-inlines-hidden SANITIZER_COMMON_CFLAGS)
endif()
append_list_if(COMPILER_RT_HAS_FNO_LTO_FLAG -fno-lto SANITIZER_COMMON_CFLAGS)

# The following is a workaround for powerpc64le. This is the only architecture
# that requires -fno-function-sections to work properly. If lacking, the ASan
# Linux test function-sections-are-bad.cc fails with the following error:
# 'undefined symbol: __sanitizer_unaligned_load32'.
if(DEFINED TARGET_powerpc64le_CFLAGS)
  append_list_if(COMPILER_RT_HAS_FNO_FUNCTION_SECTIONS_FLAG -fno-function-sections TARGET_powerpc64le_CFLAGS)
endif()

if(MSVC)
  # Replace the /M[DT][d] flags with /MT, and strip any definitions of _DEBUG,
  # which cause definition mismatches at link time.
  # FIXME: In fact, sanitizers should support both /MT and /MD, see PR20214.
  if(COMPILER_RT_HAS_MT_FLAG)
    foreach(flag_var
      CMAKE_C_FLAGS CMAKE_C_FLAGS_DEBUG CMAKE_C_FLAGS_RELEASE
      CMAKE_C_FLAGS_MINSIZEREL CMAKE_C_FLAGS_RELWITHDEBINFO
      CMAKE_CXX_FLAGS CMAKE_CXX_FLAGS_DEBUG CMAKE_CXX_FLAGS_RELEASE
      CMAKE_CXX_FLAGS_MINSIZEREL CMAKE_CXX_FLAGS_RELWITHDEBINFO)
      string(REGEX REPLACE "/M[DT]d" "/MT" ${flag_var} "${${flag_var}}")
      string(REGEX REPLACE "/MD" "/MT" ${flag_var} "${${flag_var}}")
      string(REGEX REPLACE "/D_DEBUG" "" ${flag_var} "${${flag_var}}")
    endforeach()
  endif()
  append_list_if(COMPILER_RT_HAS_Oy_FLAG /Oy- SANITIZER_COMMON_CFLAGS)
  append_list_if(COMPILER_RT_HAS_GS_FLAG /GS- SANITIZER_COMMON_CFLAGS)
  # VS 2015 (version 1900) added support for thread safe static initialization.
  # However, ASan interceptors run before CRT initialization, which causes the
  # new thread safe code to crash. Disable this feature for now.
  if (MSVC_VERSION GREATER 1899 OR "${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
    list(APPEND SANITIZER_COMMON_CFLAGS /Zc:threadSafeInit-)
  endif()
endif()

append_list_if(COMPILER_RT_DEBUG -DSANITIZER_DEBUG=1 SANITIZER_COMMON_CFLAGS)

# If we're using MSVC,
# always respect the optimization flags set by CMAKE_BUILD_TYPE instead.
if (NOT MSVC)

  # Build with optimization, unless we're in debug mode.
  if(COMPILER_RT_DEBUG)
    list(APPEND SANITIZER_COMMON_CFLAGS -O0)
  else()
    list(APPEND SANITIZER_COMMON_CFLAGS -O3)
  endif()
endif()

# Determine if we should restrict stack frame sizes.
# Stack frames on PowerPC and Mips and in debug biuld can be much larger than
# anticipated.
# FIXME: Fix all sanitizers and add -Wframe-larger-than to
# SANITIZER_COMMON_FLAGS
if(COMPILER_RT_HAS_WFRAME_LARGER_THAN_FLAG AND NOT COMPILER_RT_DEBUG
   AND NOT ${COMPILER_RT_DEFAULT_TARGET_ARCH} MATCHES "powerpc|mips")
  set(SANITIZER_LIMIT_FRAME_SIZE TRUE)
else()
  set(SANITIZER_LIMIT_FRAME_SIZE FALSE)
endif()

if(FUCHSIA OR UNIX)
  set(SANITIZER_USE_SYMBOLS TRUE)
else()
  set(SANITIZER_USE_SYMBOLS FALSE)
endif()

# Build sanitizer runtimes with debug info.
if(MSVC)
  # Use /Z7 instead of /Zi for the asan runtime. This avoids the LNK4099
  # warning from the MS linker complaining that it can't find the 'vc140.pdb'
  # file used by our object library compilations.
  list(APPEND SANITIZER_COMMON_CFLAGS /Z7)
  foreach(var_to_update
    CMAKE_CXX_FLAGS
    CMAKE_CXX_FLAGS_DEBUG
    CMAKE_CXX_FLAGS_RELWITHDEBINFO)
    string(REGEX REPLACE "(^| )/Z[i7I]($| )" " /Z7 "
           "${var_to_update}" "${${var_to_update}}")
  endforeach()
elseif(COMPILER_RT_HAS_GLINE_TABLES_ONLY_FLAG AND NOT COMPILER_RT_DEBUG)
  list(APPEND SANITIZER_COMMON_CFLAGS -gline-tables-only)
elseif(COMPILER_RT_HAS_G_FLAG)
  list(APPEND SANITIZER_COMMON_CFLAGS -g)
endif()

if(LLVM_ENABLE_MODULES)
  # Sanitizers cannot be built with -fmodules. The interceptors intentionally
  # don't include system headers, which is incompatible with modules.
  list(APPEND SANITIZER_COMMON_CFLAGS -fno-modules)
endif()

# Turn off several warnings.
append_list_if(COMPILER_RT_HAS_WGNU_FLAG -Wno-gnu SANITIZER_COMMON_CFLAGS)
append_list_if(COMPILER_RT_HAS_WVARIADIC_MACROS_FLAG -Wno-variadic-macros SANITIZER_COMMON_CFLAGS)
append_list_if(COMPILER_RT_HAS_WC99_EXTENSIONS_FLAG -Wno-c99-extensions SANITIZER_COMMON_CFLAGS)
append_list_if(COMPILER_RT_HAS_WNON_VIRTUAL_DTOR_FLAG -Wno-non-virtual-dtor SANITIZER_COMMON_CFLAGS)
append_list_if(COMPILER_RT_HAS_WD4146_FLAG /wd4146 SANITIZER_COMMON_CFLAGS)
append_list_if(COMPILER_RT_HAS_WD4291_FLAG /wd4291 SANITIZER_COMMON_CFLAGS)
append_list_if(COMPILER_RT_HAS_WD4391_FLAG /wd4391 SANITIZER_COMMON_CFLAGS)
append_list_if(COMPILER_RT_HAS_WD4722_FLAG /wd4722 SANITIZER_COMMON_CFLAGS)
append_list_if(COMPILER_RT_HAS_WD4800_FLAG /wd4800 SANITIZER_COMMON_CFLAGS)

append_list_if(MINGW -fms-extensions SANITIZER_COMMON_CFLAGS)

# Set common link flags.
append_list_if(COMPILER_RT_HAS_NODEFAULTLIBS_FLAG -nodefaultlibs SANITIZER_COMMON_LINK_FLAGS)
append_list_if(COMPILER_RT_HAS_Z_TEXT -Wl,-z,text SANITIZER_COMMON_LINK_FLAGS)

if (COMPILER_RT_USE_BUILTINS_LIBRARY)
  list(APPEND SANITIZER_COMMON_LINK_LIBS ${COMPILER_RT_BUILTINS_LIBRARY})
  string(REPLACE "-Wl,-z,defs" "" CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS}")
else()
  if (ANDROID)
    append_list_if(COMPILER_RT_HAS_GCC_LIB gcc SANITIZER_COMMON_LINK_LIBS)
  else()
    append_list_if(COMPILER_RT_HAS_GCC_S_LIB gcc_s SANITIZER_COMMON_LINK_LIBS)
  endif()
endif()

append_list_if(COMPILER_RT_HAS_LIBC c SANITIZER_COMMON_LINK_LIBS)

if("${CMAKE_SYSTEM_NAME}" STREQUAL "Fuchsia")
  list(APPEND SANITIZER_COMMON_LINK_FLAGS -Wl,-z,defs,-z,now,-z,relro)
  list(APPEND SANITIZER_COMMON_LINK_LIBS zircon)
endif()

macro(append_libcxx_libs var)
  if (${var}_INTREE)
    if (SANITIZER_USE_STATIC_LLVM_UNWINDER AND (TARGET unwind_static OR HAVE_LIBUNWIND))
      list(APPEND ${var}_LIBRARIES unwind_static)
    elseif (TARGET unwind_shared OR HAVE_LIBUNWIND)
      list(APPEND ${var}_LIBRARIES unwind_shared)
    endif()

    if (SANITIZER_USE_STATIC_CXX_ABI AND (TARGET cxxabi_static OR HAVE_LIBCXXABI))
      list(APPEND ${var}_LIBRARIES cxxabi_static)
    elseif (TARGET cxxabi_shared OR HAVE_LIBCXXABI)
      list(APPEND ${var}_LIBRARIES cxxabi_shared)
    endif()
  else()
    append_list_if(COMPILER_RT_HAS_LIBCXX c++ ${var}_LIBRARIES)
  endif()
endmacro()

if (SANITIZER_CXX_ABI_LIBNAME STREQUAL "libc++")
  append_libcxx_libs(SANITIZER_CXX_ABI)
elseif (SANITIZER_CXX_ABI_LIBNAME STREQUAL "libcxxabi")
  list(APPEND SANITIZER_CXX_ABI_LIBRARIES "c++abi")
elseif (SANITIZER_CXX_ABI_LIBNAME STREQUAL "libstdc++")
  append_list_if(COMPILER_RT_HAS_LIBSTDCXX stdc++ SANITIZER_CXX_ABI_LIBRARIES)
endif()

if (SANITIZER_TEST_CXX_LIBNAME STREQUAL "libc++")
  append_libcxx_libs(SANITIZER_TEST_CXX)
elseif (SANITIZER_TEST_CXX_LIBNAME STREQUAL "libstdc++")
  append_list_if(COMPILER_RT_HAS_LIBSTDCXX stdc++ SANITIZER_TEST_CXX_LIBRARIES)
endif()

# Warnings to turn off for all libraries, not just sanitizers.
append_string_if(COMPILER_RT_HAS_WUNUSED_PARAMETER_FLAG -Wno-unused-parameter CMAKE_C_FLAGS CMAKE_CXX_FLAGS)

if (CMAKE_LINKER MATCHES "link.exe$")
  # Silence MSVC linker warnings caused by empty object files. The
  # sanitizer libraries intentionally use ifdefs that result in empty
  # files, rather than skipping these files in the build system.
  # Ideally, we would pass this flag only for the libraries that need
  # it, but CMake doesn't seem to have a way to set linker flags for
  # individual static libraries, so we enable the suppression flag for
  # the whole compiler-rt project.
  set(CMAKE_STATIC_LINKER_FLAGS "${CMAKE_STATIC_LINKER_FLAGS} /IGNORE:4221")
endif()

add_subdirectory(include)

option(COMPILER_RT_USE_LIBCXX
  "Enable compiler-rt to use libc++ from the source tree" ON)
if(COMPILER_RT_USE_LIBCXX)
  foreach(path IN ITEMS ${LLVM_MAIN_SRC_DIR}/projects/libcxx
                        ${LLVM_MAIN_SRC_DIR}/runtimes/libcxx
                        ${LLVM_MAIN_SRC_DIR}/../libcxx
                        ${LLVM_EXTERNAL_LIBCXX_SOURCE_DIR})
    if(IS_DIRECTORY ${path})
      set(COMPILER_RT_LIBCXX_PATH ${path})
      break()
    endif()
  endforeach()
  foreach(path IN ITEMS ${LLVM_MAIN_SRC_DIR}/projects/libcxxabi
                        ${LLVM_MAIN_SRC_DIR}/runtimes/libcxxabi
                        ${LLVM_MAIN_SRC_DIR}/../libcxxabi
                        ${LLVM_EXTERNAL_LIBCXXABI_SOURCE_DIR})
    if(IS_DIRECTORY ${path})
      set(COMPILER_RT_LIBCXXABI_PATH ${path})
      break()
    endif()
  endforeach()
endif()

set(COMPILER_RT_LLD_PATH ${LLVM_MAIN_SRC_DIR}/tools/lld)
if(EXISTS ${COMPILER_RT_LLD_PATH}/ AND LLVM_TOOL_LLD_BUILD)
  set(COMPILER_RT_HAS_LLD TRUE)
else()
  set(COMPILER_RT_LLD_PATH ${LLVM_MAIN_SRC_DIR}/../lld)
  if(EXISTS ${COMPILER_RT_LLD_PATH}/ AND LLVM_TOOL_LLD_BUILD)
    set(COMPILER_RT_HAS_LLD TRUE)
  else()
    set(COMPILER_RT_HAS_LLD FALSE)
  endif()
endif()
pythonize_bool(COMPILER_RT_HAS_LLD)

add_subdirectory(lib)

if(COMPILER_RT_INCLUDE_TESTS AND XXX_DISABLE_NYUZI)
  add_subdirectory(unittests)
  add_subdirectory(test)
  if (COMPILER_RT_STANDALONE_BUILD)
    # If we have a valid source tree, generate llvm-lit into the bin directory.
    # The user can still choose to have the check targets *use* a different lit
    # by specifying -DLLVM_EXTERNAL_LIT, but we generate it regardless.
    if (EXISTS ${LLVM_MAIN_SRC_DIR}/utils/llvm-lit)
      add_subdirectory(${LLVM_MAIN_SRC_DIR}/utils/llvm-lit ${CMAKE_CURRENT_BINARY_DIR}/llvm-lit)
    elseif(NOT EXISTS ${LLVM_EXTERNAL_LIT})
      message(WARNING "Could not find LLVM source directory and LLVM_EXTERNAL_LIT does not"
                       "point to a valid file.  You will not be able to run tests.")
    endif()
  endif()
endif()
