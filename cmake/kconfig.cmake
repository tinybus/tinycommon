macro(kconfig_to_tiny_option kconfig_option tiny_config description)
  if(${kconfig_option})
    set(${tiny_config}
        ON
        CACHE BOOL "${description}" FORCE)
  else()
    set(${tiny_config}
        OFF
        CACHE BOOL "${description}" FORCE)
  endif()
endmacro()
