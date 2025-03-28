# Constructor with an explicitly given name.
macro(tiny_library_named name)
  # This is a macro because we need add_library() to be executed within the
  # scope of the caller.
  set(TY_CURRENT_LIBRARY ${name})
  add_library(${name} STATIC "")

  tiny_append_cmake_library(${name})
endmacro()

#
# tiny_library versions of normal CMake target_<func> functions Note, paths
# passed to this function must be relative in order to support the library
# relocation feature of tiny_code_relocate
#
function(tiny_library_sources source)
  target_sources(${TY_CURRENT_LIBRARY} PRIVATE ${source} ${ARGN})
endfunction()

function(tiny_library_include_directories)
  target_include_directories(${TY_CURRENT_LIBRARY} PRIVATE ${ARGN})
endfunction()

function(tiny_library_include_directories_public)
  target_include_directories(${TINY_CURRENT_LIBRARY} PUBLIC ${ARGN})
endfunction()

function(tiny_library_link_libraries item)
  target_link_libraries(${TY_CURRENT_LIBRARY} PUBLIC ${item} ${ARGN})
endfunction()

function(tiny_library_compile_definitions item)
  target_compile_definitions(${TY_CURRENT_LIBRARY} PRIVATE ${item} ${ARGN})
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
  set_property(GLOBAL APPEND PROPERTY TY_LIBS ${library})
endfunction()

function(tiny_library_sources_ifdef feature_toggle)
  if(${${feature_toggle}})
    tiny_library_sources(${ARGN})
  endif()
endfunction()

# https://cmake.org/cmake/help/latest/command/target_compile_definitions.html
function(tiny_library_compile_definitions)
  target_compile_definitions(${TINY_CURRENT_LIBRARY} PRIVATE ${ARGV})
endfunction()
