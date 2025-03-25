# 1.2 tiny_library_*
#
# Tiny libraries use CMake's library concept and a set of assumptions about how
# zephyr code is organized to cut down on boilerplate code.
#
# A Tiny library can be constructed by the function tiny_library or
# tiny_library_named. The constructors create a CMake library with a name
# accessible through the variable TINY_CURRENT_LIBRARY.
#
# The variable TINY_CURRENT_LIBRARY should seldom be needed since the zephyr
# libraries have methods that modify the libraries. These methods have the
# signature: tiny_library_<target-function>
#
# The methods are wrappers around the CMake target_* functions. See
# https://cmake.org/cmake/help/latest/manual/cmake-commands.7.html for
# documentation on the underlying target_* functions.
#
# The methods modify the CMake target_* API to reduce boilerplate; PRIVATE is
# assumed The target is assumed to be TINY_CURRENT_LIBRARY
#
# When a flag that is given through the tiny_* API conflicts with the
# tiny_library_* API then precedence will be given to the tiny_library_* API. In
# other words, local configuration overrides global configuration.

# Constructor with an explicitly given name.
macro(tiny_library_named name)
  # This is a macro because we need add_library() to be executed within the
  # scope of the caller.
  set(TINY_CURRENT_LIBRARY ${name})
  add_library(${name} STATIC "")

  tiny_append_cmake_library(${name})

  target_link_libraries(${name} PUBLIC tiny_interface)
endmacro()

#
# tiny_library versions of normal CMake target_<func> functions Note, paths
# passed to this function must be relative in order to support the library
# relocation feature of tiny_code_relocate
#
function(tiny_library_sources source)
  target_sources(${TINY_CURRENT_LIBRARY} PRIVATE ${source} ${ARGN})
endfunction()

function(tiny_library_include_directories)
  target_include_directories(${TINY_CURRENT_LIBRARY} PRIVATE ${ARGN})
endfunction()

function(tiny_library_link_libraries item)
  target_link_libraries(${TINY_CURRENT_LIBRARY} PUBLIC ${item} ${ARGN})
endfunction()

function(tiny_library_compile_definitions item)
  target_compile_definitions(${TINY_CURRENT_LIBRARY} PRIVATE ${item} ${ARGN})
endfunction()

# Add the existing CMake library 'library' to the global list of Tiny CMake
# libraries. This is done automatically by the constructor but must be called
# explicitly on CMake libraries that do not use a zephyr library constructor.
function(tiny_append_cmake_library library)
  if(TARGET tiny_prebuilt)
    message(
      WARNING
        "tiny_library() or tiny_library_named() called in Tiny CMake "
        "application mode. `${library}` will not be treated as a Tiny library."
        "To create a Tiny library in Tiny CMake kernel mode consider "
        "creating a Tiny module. See more here: "
        "https://docs.zephyrproject.org/latest/guides/modules.html")
  endif()
  set_property(GLOBAL APPEND PROPERTY TINY_LIBS ${library})
endfunction()

# https://cmake.org/cmake/help/latest/command/target_link_libraries.html
function(tiny_link_libraries)
  if(ARGV0 STREQUAL "PROPERTY")
    set(property $<TARGET_PROPERTY:linker,${ARGV1}>)
    set(property_defined $<BOOL:${property}>)
    if(ARGC GREATER 3)
      message(FATAL_ERROR "tiny_link_options(PROPERTY <prop> [<val>]) "
                          "called with too many arguments.")
    elseif(ARGC EQUAL 3)
      target_link_libraries(
        tiny_interface INTERFACE $<${property_defined}:${property}${ARGV2}>)
    else()
      target_link_libraries(tiny_interface INTERFACE ${property})
    endif()
  else()
    target_link_libraries(tiny_interface INTERFACE ${ARGV})
  endif()
endfunction()

function(tiny_sources)
  foreach(arg ${ARGV})
    if(IS_DIRECTORY ${arg})
      message(FATAL_ERROR "tiny_sources() was called on a directory")
    endif()
    target_sources(tiny PRIVATE ${arg})
  endforeach()
endfunction()

function(tiny_sources_ifdef feature_toggle)
  if(${${feature_toggle}})
    tiny_sources(${ARGN})
  endif()
endfunction()

# https://cmake.org/cmake/help/latest/command/target_include_directories.html
function(tiny_include_directories)
  target_include_directories(tiny_interface INTERFACE ${ARGV})
endfunction()

# https://cmake.org/cmake/help/latest/command/target_compile_definitions.html
function(tiny_compile_definitions)
  target_compile_definitions(tiny_interface INTERFACE ${ARGV})
endfunction()
