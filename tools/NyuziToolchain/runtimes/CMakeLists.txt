# This file handles building LLVM runtime sub-projects.

# Runtimes are different from tools or other drop-in projects because runtimes
# should be built with the LLVM toolchain from the build directory. This file is
# a first step to formalizing runtime build interfaces.

# In the current state this file only works with compiler-rt, other runtimes
# will work as the runtime build interface standardizes.

# Find all subdirectories containing CMake projects
file(GLOB entries *)
foreach(entry ${entries})
  if(IS_DIRECTORY ${entry} AND EXISTS ${entry}/CMakeLists.txt)
    list(APPEND runtimes ${entry})
  endif()
endforeach()

# Side-by-side subprojects layout.
set(LLVM_ALL_RUNTIMES "libcxx;libcxxabi;libunwind;compiler-rt")
set(LLVM_ENABLE_RUNTIMES "" CACHE STRING
  "Semicolon-separated list of runtimes to build (${LLVM_ALL_RUNTIMES}), or \"all\".")
if(LLVM_ENABLE_RUNTIMES STREQUAL "all" )
  set(LLVM_ENABLE_RUNTIMES ${LLVM_ALL_RUNTIMES})
endif()
foreach(proj ${LLVM_ENABLE_RUNTIMES})
  set(proj_dir "${CMAKE_CURRENT_SOURCE_DIR}/../../${proj}")
  if(IS_DIRECTORY ${proj_dir} AND EXISTS ${proj_dir}/CMakeLists.txt)
    list(APPEND runtimes ${proj_dir})
  else()
    message(FATAL_ERROR "LLVM_ENABLE_RUNTIMES requests ${proj} but directory not found: ${proj_dir}")
  endif()
  string(TOUPPER "${proj}" canon_name)
  STRING(REGEX REPLACE "-" "_" canon_name ${canon_name})
  set(LLVM_EXTERNAL_${canon_name}_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../${proj}")
endforeach()

function(get_compiler_rt_path path)
  foreach(entry ${runtimes})
    get_filename_component(projName ${entry} NAME)
    if("${projName}" MATCHES "compiler-rt")
      set(${path} ${entry} PARENT_SCOPE)
      return()
    endif()
  endforeach()
endfunction()

# If this file is acting as a top-level CMake invocation, this code path is
# triggered by the external project call for the runtimes target below.
if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_CURRENT_SOURCE_DIR})

  function(runtime_register_component name)
    set_property(GLOBAL APPEND PROPERTY SUB_COMPONENTS ${name})
  endfunction()

  cmake_minimum_required(VERSION 3.4.3)
  project(Runtimes C CXX ASM)

  # Add the root project's CMake modules, and the LLVM build's modules to the
  # CMake module path.
  list(INSERT CMAKE_MODULE_PATH 0
    "${CMAKE_CURRENT_SOURCE_DIR}/../cmake"
    "${CMAKE_CURRENT_SOURCE_DIR}/../cmake/modules"
    "${LLVM_LIBRARY_DIR}/cmake/llvm"
  )

  # Some of the runtimes will conditionally use the compiler-rt sanitizers
  # to make this work smoothly we ensure that compiler-rt is added first in
  # the list of sub-projects. This allows other sub-projects to have checks
  # like `if(TARGET asan)` to enable building with asan.
  get_compiler_rt_path(compiler_rt_path)
  if(compiler_rt_path)
    list(REMOVE_ITEM runtimes ${compiler_rt_path})
    if(NOT LLVM_BUILD_COMPILER_RT)
      list(INSERT runtimes 0 ${compiler_rt_path})
    endif()
  endif()

  # LLVMConfig.cmake contains a bunch of CMake variables from the LLVM build.
  # This file is installed as part of LLVM distributions, so this can be used
  # either from a build directory or an installed LLVM.
  include(LLVMConfig)

  # Setting these variables will allow the sub-build to put their outputs into
  # the library and bin directories of the top-level build.
  set(LLVM_LIBRARY_OUTPUT_INTDIR ${LLVM_LIBRARY_DIR})
  set(LLVM_RUNTIME_OUTPUT_INTDIR ${LLVM_TOOLS_BINARY_DIR})

  # This variable makes sure that e.g. llvm-lit is found.
  set(LLVM_MAIN_SRC_DIR ${LLVM_BUILD_MAIN_SRC_DIR})
  set(LLVM_CMAKE_PATH ${LLVM_MAIN_SRC_DIR}/cmake/modules)

  if(APPLE AND XXX_DISABLE_NYUZI)
    set(LLVM_ENABLE_LIBCXX ON CACHE BOOL "")
  endif()

  include(CheckLibraryExists)
  include(CheckCCompilerFlag)

  # We don't have libc++ (yet).
  set(CMAKE_REQUIRED_FLAGS "${CMAKE_REQUIRED_FLAGS} -nostdlib++")

  # Avoid checking whether the compiler is working.
  set(LLVM_COMPILER_CHECKED ON)

  # Enable warnings, otherwise -w gets added to the cflags by HandleLLVMOptions
  # resulting in unjustified successes by check_cxx_compiler_flag.
  set(LLVM_ENABLE_WARNINGS ON)

  # Handle common options used by all runtimes.
  include(AddLLVM)
  include(HandleLLVMOptions)
  include(FindPythonInterp)

  # Remove the -nostdlib++ option we've added earlier.
  string(REPLACE "-nostdlib++" "" CMAKE_REQUIRED_FLAGS "${CMAKE_REQUIRED_FLAGS}")

  # This can be used to detect whether we're in the runtimes build.
  set(RUNTIMES_BUILD ON)

  foreach(entry ${runtimes})
    get_filename_component(projName ${entry} NAME)

    # TODO: Clean this up as part of an interface standardization
    string(REPLACE "-" "_" canon_name ${projName})
    string(TOUPPER ${canon_name} canon_name)

    if(LLVM_RUNTIMES_LIBDIR_SUFFIX)
      set(${canon_name}_LIBDIR_SUFFIX "${LLVM_RUNTIMES_LIBDIR_SUFFIX}" CACHE STRING "" FORCE)
    endif()

    # Setting a variable to let sub-projects detect which other projects
    # will be included under here.
    set(HAVE_${canon_name} ON)
  endforeach()

  # We do this in two loops so that HAVE_* is set for each runtime before the
  # other runtimes are added.
  foreach(entry ${runtimes})
    get_filename_component(projName ${entry} NAME)

    # Between each sub-project we want to cache and clear the LIT properties
    set_property(GLOBAL PROPERTY LLVM_LIT_TESTSUITES)
    set_property(GLOBAL PROPERTY LLVM_LIT_PARAMS)
    set_property(GLOBAL PROPERTY LLVM_LIT_DEPENDS)
    set_property(GLOBAL PROPERTY LLVM_LIT_EXTRA_ARGS)

    add_subdirectory(${entry} ${projName})

    get_property(LLVM_LIT_TESTSUITES GLOBAL PROPERTY LLVM_LIT_TESTSUITES)
    get_property(LLVM_LIT_PARAMS GLOBAL PROPERTY LLVM_LIT_PARAMS)
    get_property(LLVM_LIT_DEPENDS GLOBAL PROPERTY LLVM_LIT_DEPENDS)
    get_property(LLVM_LIT_EXTRA_ARGS GLOBAL PROPERTY LLVM_LIT_EXTRA_ARGS)

    list(APPEND RUNTIMES_LIT_TESTSUITES ${LLVM_LIT_TESTSUITES})
    list(APPEND RUNTIMES_LIT_PARAMS ${LLVM_LIT_PARAMS})
    list(APPEND RUNTIMES_LIT_DEPENDS ${LLVM_LIT_DEPENDS})
    list(APPEND RUNTIMES_LIT_EXTRA_ARGS ${LLVM_LIT_EXTRA_ARGS})
  endforeach()

  if(LLVM_INCLUDE_TESTS AND XXX_DISABLE_NYUZI)
    # Add a global check rule now that all subdirectories have been traversed
    # and we know the total set of lit testsuites.

    #add_lit_target(check-runtimes
    #  "Running all regression tests"
    #  ${RUNTIMES_LIT_TESTSUITES}
    #  PARAMS ${RUNTIMES_LIT_PARAMS}
    #  DEPENDS ${RUNTIMES_LIT_DEPENDS}
    #  ARGS ${RUNTIMES_LIT_EXTRA_ARGS}
    #  )
    add_custom_target(runtimes-test-depends DEPENDS ${RUNTIMES_LIT_DEPENDS})
  endif()

  get_property(SUB_COMPONENTS GLOBAL PROPERTY SUB_COMPONENTS)
  if(SUB_COMPONENTS)
    list(REMOVE_DUPLICATES SUB_COMPONENTS)
    foreach(component ${SUB_COMPONENTS})
      if(NOT TARGET ${component})
        message(SEND_ERROR "Missing target for runtime component ${component}!")
        continue()
      endif()

      if(TARGET check-${component})
        list(APPEND SUB_CHECK_TARGETS check-${component})
      endif()

      if(TARGET install-${component})
        list(APPEND SUB_INSTALL_TARGETS install-${component})
      endif()
      if(TARGET install-${component}-stripped)
        list(APPEND SUB_INSTALL_TARGETS install-${component}-stripped)
      endif()
    endforeach()

    if(LLVM_RUNTIMES_TARGET)
      configure_file(
        ${CMAKE_CURRENT_SOURCE_DIR}/Components.cmake.in
        ${LLVM_BINARY_DIR}/runtimes/${LLVM_RUNTIMES_TARGET}/Components.cmake)
    else()
      configure_file(
        ${CMAKE_CURRENT_SOURCE_DIR}/Components.cmake.in
        ${LLVM_BINARY_DIR}/runtimes/Components.cmake)
    endif()
  endif()

else() # if this is included from LLVM's CMake
  include(LLVMExternalProjectUtils)

  if(NOT LLVM_BUILD_RUNTIMES)
    set(EXTRA_ARGS EXCLUDE_FROM_ALL)
  endif()

  function(builtin_default_target compiler_rt_path)
    cmake_parse_arguments(ARG "" "" "DEPENDS" ${ARGN})

    llvm_ExternalProject_Add(builtins
                             ${compiler_rt_path}/lib/builtins
                             DEPENDS ${ARG_DEPENDS}
                             CMAKE_ARGS -DLLVM_LIBRARY_OUTPUT_INTDIR=${LLVM_LIBRARY_DIR}
                                        -DLLVM_RUNTIME_OUTPUT_INTDIR=${LLVM_TOOLS_BINARY_DIR}
                                        -DLLVM_DEFAULT_TARGET_TRIPLE=${TARGET_TRIPLE}
                                        -DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=OFF
                                        -DCMAKE_C_COMPILER_TARGET=${TARGET_TRIPLE}
                                        -DCMAKE_ASM_COMPILER_TARGET=${TARGET_TRIPLE}
                                        -DCMAKE_C_COMPILER_WORKS=ON
                                        -DCMAKE_ASM_COMPILER_WORKS=ON
                             PASSTHROUGH_PREFIXES COMPILER_RT
                             USE_TOOLCHAIN
                             ${EXTRA_ARGS})
  endfunction()

  function(builtin_register_target compiler_rt_path target)
    cmake_parse_arguments(ARG "" "" "DEPENDS" ${ARGN})

    string(REPLACE "-" ";" builtin_target_list ${target})
    foreach(item ${builtin_target_list})
      string(TOLOWER "${item}" item_lower)
      if(item_lower MATCHES "darwin")
        message(FATAL_ERROR "LLVM_BUILTIN_TARGETS isn't implemented for Darwin platform!")
      endif()
    endforeach()

    get_cmake_property(variableNames VARIABLES)
    foreach(variableName ${variableNames})
      if(variableName MATCHES "^BUILTINS_${target}")
        string(REPLACE "BUILTINS_${target}_" "" new_name ${variableName})
        list(APPEND ${target}_extra_args "-D${new_name}=${${variableName}}")
      endif()
    endforeach()

    llvm_ExternalProject_Add(builtins-${target}
                             ${compiler_rt_path}/lib/builtins
                             DEPENDS ${ARG_DEPENDS}
                             CMAKE_ARGS -DLLVM_LIBRARY_OUTPUT_INTDIR=${LLVM_LIBRARY_DIR}
                                        -DLLVM_RUNTIME_OUTPUT_INTDIR=${LLVM_TOOLS_BINARY_DIR}
                                        -DLLVM_DEFAULT_TARGET_TRIPLE=${target}
                                        -DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=OFF
                                        -DCMAKE_C_COMPILER_TARGET=${target}
                                        -DCMAKE_ASM_COMPILER_TARGET=${target}
                                        -DCMAKE_C_COMPILER_WORKS=ON
                                        -DCMAKE_ASM_COMPILER_WORKS=ON
                                        -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON
                                        ${${target}_extra_args}
                             TOOLCHAIN_TOOLS clang lld llvm-ar llvm-ranlib llvm-nm llvm-objcopy llvm-objdump llvm-strip
                             USE_TOOLCHAIN
                             ${EXTRA_ARGS})
  endfunction()

  # If compiler-rt is present we need to build the builtin libraries first. This
  # is required because the other runtimes need the builtin libraries present
  # before the just-built compiler can pass the configuration tests.
  get_compiler_rt_path(compiler_rt_path)
  if(compiler_rt_path)
    if(NOT LLVM_BUILTIN_TARGETS)
      builtin_default_target(${compiler_rt_path}
        DEPENDS clang-resource-headers)
    else()
      if("default" IN_LIST LLVM_BUILTIN_TARGETS)
        builtin_default_target(${compiler_rt_path}
          DEPENDS clang-resource-headers)
        list(REMOVE_ITEM LLVM_BUILTIN_TARGETS "default")
      else()
        add_custom_target(builtins)
        add_custom_target(install-builtins)
        add_custom_target(install-builtins-stripped)
      endif()

      foreach(target ${LLVM_BUILTIN_TARGETS})
        builtin_register_target(${compiler_rt_path} ${target}
          DEPENDS clang-resource-headers)

        add_dependencies(builtins builtins-${target})
        add_dependencies(install-builtins install-builtins-${target})
        add_dependencies(install-builtins-stripped install-builtins-${target}-stripped)
      endforeach()
    endif()
    set(deps builtins)
    # We don't need to depend on the builtins if we're building instrumented
    # because the next stage will use the same compiler used to build this stage.
    if(NOT LLVM_BUILD_INSTRUMENTED AND CLANG_ENABLE_BOOTSTRAP)
      add_dependencies(clang-bootstrap-deps builtins)
    endif()
  endif()

  # We create a list the names of all the runtime projects in all uppercase and
  # with dashes turned to underscores. This gives us the CMake variable prefixes
  # for all variables that will apply to runtimes.
  foreach(entry ${runtimes})
    get_filename_component(projName ${entry} NAME)
    string(REPLACE "-" "_" canon_name ${projName})
    string(TOUPPER ${canon_name} canon_name)
    list(APPEND prefixes ${canon_name})

    string(FIND ${projName} "lib" LIB_IDX)
    if(LIB_IDX EQUAL 0)
      string(SUBSTRING ${projName} 3 -1 projName)
    endif()
    list(APPEND runtime_names ${projName})
  endforeach()

  if(LLVM_RUNTIME_BUILD_ID_LINK_TARGETS)
    configure_file(
      ${CMAKE_CURRENT_SOURCE_DIR}/llvm-strip-link.in
      ${CMAKE_CURRENT_BINARY_DIR}/llvm-strip-link
      @ONLY
    )
  endif()

  function(runtime_default_target)
    cmake_parse_arguments(ARG "" "" "DEPENDS;PREFIXES" ${ARGN})

    include(${LLVM_BINARY_DIR}/runtimes/Components.cmake OPTIONAL)
    set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS ${LLVM_BINARY_DIR}/runtimes/Components.cmake)

    foreach(runtime_name ${runtime_names})
      list(APPEND extra_targets
        ${runtime_name}
        install-${runtime_name}
        install-${runtime_name}-stripped)
      #if(LLVM_INCLUDE_TESTS)
      #  list(APPEND test_targets check-${runtime_name})
      #endif()
    endforeach()
    foreach(component ${LLVM_RUNTIME_DISTRIBUTION_COMPONENTS})
      if(NOT ${component} IN_LIST SUB_COMPONENTS)
        list(APPEND extra_targets ${component} install-${component} install-${component}-stripped)
      endif()
    endforeach()

    if(LLVM_INCLUDE_TESTS)
      list(APPEND test_targets runtimes-test-depends check-runtimes)
    endif()

    if(FALSE)
    llvm_ExternalProject_Add(runtimes
                             ${CMAKE_CURRENT_SOURCE_DIR}
                             DEPENDS ${ARG_DEPENDS}
                             # Builtins were built separately above
                             CMAKE_ARGS -DCOMPILER_RT_BUILD_BUILTINS=Off
                                        -DLLVM_INCLUDE_TESTS=${LLVM_INCLUDE_TESTS}
                                        -DLLVM_LIBRARY_DIR=${LLVM_LIBRARY_DIR}
                                        -DLLVM_DEFAULT_TARGET_TRIPLE=${TARGET_TRIPLE}
                                        -DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=OFF
                                        -DCMAKE_C_COMPILER_TARGET=${TARGET_TRIPLE}
                                        -DCMAKE_CXX_COMPILER_TARGET=${TARGET_TRIPLE}
                                        -DCMAKE_ASM_COMPILER_TARGET=${TARGET_TRIPLE}
                                        -DCMAKE_C_COMPILER_WORKS=ON
                                        -DCMAKE_CXX_COMPILER_WORKS=ON
                                        -DCMAKE_ASM_COMPILER_WORKS=ON
                             PASSTHROUGH_PREFIXES LLVM_ENABLE_RUNTIMES
                                                  ${ARG_PREFIXES}
                             EXTRA_TARGETS ${extra_targets}
                                           ${test_targets}
                                           ${SUB_COMPONENTS}
                                           ${SUB_CHECK_TARGETS}
                                           ${SUB_INSTALL_TARGETS}
                             USE_TOOLCHAIN
                             ${EXTRA_ARGS})
    endif()
  endfunction()

  # runtime_register_target(target)
  #   Utility function to register external runtime target.
  function(runtime_register_target name target)
    cmake_parse_arguments(ARG "" "" "DEPENDS" ${ARGN})
    include(${LLVM_BINARY_DIR}/runtimes/${name}/Components.cmake OPTIONAL)
    set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS ${LLVM_BINARY_DIR}/runtimes/${name}/Components.cmake)

    set(${name}_deps ${ARG_DEPENDS})
    if(NOT name STREQUAL target)
      list(APPEND ${name}_deps runtimes-${target})
    endif()

    foreach(runtime_name ${runtime_names})
      set(${runtime_name}-${name} ${runtime_name})
      set(install-${runtime_name}-${name} install-${runtime_name})
      set(install-${runtime_name}-${name}-stripped install-${runtime_name}-stripped)
      list(APPEND ${name}_extra_targets ${runtime_name}-${name} install-${runtime_name}-${name} install-${runtime_name}-${name}-stripped)
      if(LLVM_INCLUDE_TESTS)
        set(check-${runtime_name}-${name} check-${runtime_name} )
        list(APPEND ${name}_test_targets check-${runtime_name}-${name})
      endif()
    endforeach()

    foreach(target_name IN LISTS SUB_COMPONENTS SUB_INSTALL_TARGETS)
      set(${target_name}-${name} ${target_name})
      list(APPEND ${name}_extra_targets ${target_name}-${name})
    endforeach()

    foreach(component ${LLVM_RUNTIME_DISTRIBUTION_COMPONENTS})
      set(${component}-${name} ${component})
      set(install-${component}-${name} ${component})
      list(APPEND ${name}_extra_targets ${component}-${name} install-${component}-${name})
    endforeach()

    if(LLVM_INCLUDE_TESTS)
      set(runtimes-test-depends-${name} runtimes-test-depends)
#      set(check-runtimes-${name} check-runtimes)
#      list(APPEND ${name}_test_targets runtimes-test-depends-${name} check-runtimes-${name})
      foreach(target_name IN LISTS SUB_CHECK_TARGETS)
        set(${target_name}-${name} ${target_name})
        list(APPEND ${name}_test_targets ${target_name}-${name})
        list(APPEND test_targets ${target_name}-${name})
      endforeach()
      set(test_targets "${test_targets}" PARENT_SCOPE)
    endif()

    get_cmake_property(variableNames VARIABLES)
    foreach(variableName ${variableNames})
      if(variableName MATCHES "^RUNTIMES_${name}")
        string(REPLACE "RUNTIMES_${name}_" "" new_name ${variableName})
        list(APPEND ${name}_extra_args "-D${new_name}=${${variableName}}")
      elseif(variableName MATCHES "^RUNTIMES_${target}")
        string(REPLACE "RUNTIMES_${target}_" "" new_name ${variableName})
        list(APPEND ${name}_extra_args "-D${new_name}=${${variableName}}")
      endif()
    endforeach()

    if(target IN_LIST LLVM_RUNTIME_BUILD_ID_LINK_TARGETS)
      list(APPEND EXTRA_ARGS STRIP_TOOL ${CMAKE_CURRENT_BINARY_DIR}/llvm-strip-link)
    endif()

    llvm_ExternalProject_Add(runtimes-${name}
                             ${CMAKE_CURRENT_SOURCE_DIR}
                             DEPENDS ${${name}_deps}
                             # Builtins were built separately above
                             CMAKE_ARGS -DCOMPILER_RT_BUILD_BUILTINS=Off
                                        -DLLVM_INCLUDE_TESTS=${LLVM_INCLUDE_TESTS}
                                        -DLLVM_LIBRARY_DIR=${LLVM_LIBRARY_DIR}
                                        -DLLVM_DEFAULT_TARGET_TRIPLE=${target}
                                        -DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=OFF
                                        -DCMAKE_C_COMPILER_TARGET=${target}
                                        -DCMAKE_CXX_COMPILER_TARGET=${target}
                                        -DCMAKE_ASM_COMPILER_TARGET=${target}
                                        -DCMAKE_C_COMPILER_WORKS=ON
                                        -DCMAKE_CXX_COMPILER_WORKS=ON
                                        -DCMAKE_ASM_COMPILER_WORKS=ON
                                        -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON
                                        -DLLVM_RUNTIMES_TARGET=${name}
                                        ${${name}_extra_args}
                             PASSTHROUGH_PREFIXES LLVM_ENABLE_RUNTIMES
                             TOOLCHAIN_TOOLS clang lld llvm-ar llvm-ranlib llvm-nm llvm-objcopy llvm-objdump llvm-strip
                             EXTRA_TARGETS ${${name}_extra_targets}
                                           ${${name}_test_targets}
                             USE_TOOLCHAIN
                             ${EXTRA_ARGS})
  endfunction()

  if(runtimes)
    # Create a runtimes target that uses this file as its top-level CMake file.
    # The runtimes target is a configuration of all the runtime libraries
    # together in a single CMake invocaiton.
    if(NOT LLVM_RUNTIME_TARGETS)
      runtime_default_target(
        DEPENDS ${deps}
        PREFIXES ${prefixes})
    else()
      if("default" IN_LIST LLVM_RUNTIME_TARGETS)
        runtime_default_target(
          DEPENDS ${deps}
          PREFIXES ${prefixes})
        list(REMOVE_ITEM LLVM_RUNTIME_TARGETS "default")
      else()
        add_custom_target(runtimes)
        add_custom_target(runtimes-configure)
        add_custom_target(install-runtimes)
        add_custom_target(install-runtimes-stripped)
        if(LLVM_INCLUDE_TESTS)
#          add_custom_target(check-runtimes)
          add_custom_target(runtimes-test-depends)
          set(test_targets "")
        endif()
        if(LLVM_RUNTIME_DISTRIBUTION_COMPONENTS)
          foreach(component ${LLVM_RUNTIME_DISTRIBUTION_COMPONENTS})
            add_custom_target(${component})
            add_custom_target(install-${component})
          endforeach()
        endif()
      endif()

      foreach(name ${LLVM_RUNTIME_TARGETS})
        runtime_register_target(${name} ${name}
          DEPENDS ${deps})

        add_dependencies(runtimes runtimes-${name})
        add_dependencies(runtimes-configure runtimes-${name}-configure)
        add_dependencies(install-runtimes install-runtimes-${name})
        add_dependencies(install-runtimes-stripped install-runtimes-${name}-stripped)
        if(LLVM_INCLUDE_TESTS)
#          add_dependencies(check-runtimes check-runtimes-${name})
          add_dependencies(runtimes-test-depends runtimes-test-depends-${name})
        endif()
      endforeach()

      foreach(sanitizer ${LLVM_RUNTIME_SANITIZERS})
        if (sanitizer STREQUAL "Address")
          set(sanitizer_name "asan")
        elseif (sanitizer STREQUAL "Memory")
          set(sanitizer_name "msan")
        elseif (sanitizer STREQUAL "Thread")
          set(sanitizer_name "tsan")
        elseif (sanitizer STREQUAL "Undefined")
          set(sanitizer_name "ubsan")
        else()
          message(FATAL_ERROR "Unsupported value of LLVM_RUNTIME_TARGET_SANITIZERS: ${sanitizers}")
        endif()
        foreach(name ${LLVM_RUNTIME_SANITIZER_${sanitizer}_TARGETS})
          runtime_register_target(${name}-${sanitizer_name} ${name}
            DEPENDS runtimes-${name}
            CMAKE_ARGS -DLLVM_USE_SANITIZER=${sanitizer}
                       -DLLVM_RUNTIMES_PREFIX=${name}/
                       -DLLVM_RUNTIMES_LIBDIR_SUFFIX=/${sanitizer_name})
          add_dependencies(runtimes runtimes-${name}-${sanitizer_name})
          add_dependencies(runtimes-configure runtimes-${name}-${sanitizer_name}-configure)
          add_dependencies(install-runtimes install-runtimes-${name}-${sanitizer_name})
          add_dependencies(install-runtimes-stripped install-runtimes-${name}-${sanitizer_name}-stripped)
        endforeach()
      endforeach()
    endif()

    # TODO: This is a hack needed because the libcxx headers are copied into the
    # build directory during configuration. Without that step the clang in the
    # build directory cannot find the C++ headers in certain configurations.
    # I need to build a mechanism for runtime projects to provide CMake code
    # that executes at LLVM configuration time to handle this case.
    if(NOT LLVM_BUILD_INSTRUMENTED AND CLANG_ENABLE_BOOTSTRAP)
      add_dependencies(clang-bootstrap-deps runtimes-configure)
    endif()

    if(LLVM_INCLUDE_TESTS)
      set_property(GLOBAL APPEND PROPERTY LLVM_ADDITIONAL_TEST_DEPENDS runtimes-test-depends)
#      set_property(GLOBAL APPEND PROPERTY LLVM_ADDITIONAL_TEST_TARGETS check-runtimes)

      set(RUNTIMES_TEST_DEPENDS
          FileCheck
          count
          llvm-nm
          llvm-objdump
          llvm-xray
          not
          obj2yaml
          sancov
          sanstats
        )
      foreach(target ${test_targets} ${SUB_CHECK_TARGETS})
        add_dependencies(${target} ${RUNTIMES_TEST_DEPENDS})
      endforeach()
    endif()
  endif()
endif()
