# Constructor with an explicitly given name.
macro(ty_library_named name)
  # This is a macro because we need add_library() to be executed within the
  # scope of the caller.
  set(TY_CURRENT_LIBRARY ${name})
  add_library(${name} STATIC "")

  ty_append_cmake_library(${name})
endmacro()

#
# ty_library versions of normal CMake target_<func> functions Note, paths passed
# to this function must be relative in order to support the library relocation
# feature of ty_code_relocate
#
function(ty_library_sources source)
  target_sources(${TY_CURRENT_LIBRARY} PRIVATE ${source} ${ARGN})
endfunction()

function(ty_library_include_directories)
  target_include_directories(${TY_CURRENT_LIBRARY} PRIVATE ${ARGN})
endfunction()

function(ty_library_include_directories_public)
  target_include_directories(${TY_CURRENT_LIBRARY} PUBLIC ${ARGN})
endfunction()

function(ty_library_link_libraries item)
  target_link_libraries(${TY_CURRENT_LIBRARY} PUBLIC ${item} ${ARGN})
endfunction()

function(ty_library_compile_definitions item)
  target_compile_definitions(${TY_CURRENT_LIBRARY} PRIVATE ${item} ${ARGN})
endfunction()

# Add the existing CMake library 'library' to the global list of TY CMake
# libraries. This is done automatically by the constructor but must be called
# explicitly on CMake libraries that do not use a zephyr library constructor.
function(ty_append_cmake_library library)
  if(TARGET ty_prebuilt)
    message(
      WARNING
        "ty_library() or ty_library_named() called in TY CMake "
        "application mode. `${library}` will not be treated as a TY library."
        "To create a TY library in TY CMake kernel mode consider "
        "creating a TY module. See more here: "
        "https://docs.zephyrproject.org/latest/guides/modules.html")
  endif()
  set_property(GLOBAL APPEND PROPERTY TY_LIBS ${library})
endfunction()

function(ty_library_sources_ifdef feature_toggle)
  if(${${feature_toggle}})
    ty_library_sources(${ARGN})
  endif()
endfunction()

# https://cmake.org/cmake/help/latest/command/target_compile_definitions.html
function(ty_library_compile_definitions)
  target_compile_definitions(${TY_CURRENT_LIBRARY} PRIVATE ${ARGV})
endfunction()
