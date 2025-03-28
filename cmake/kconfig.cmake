macro(kconfig_to_ty_option kconfig_option ty_config description)
  if(${kconfig_option})
    set(${ty_config}
        ON
        CACHE BOOL "${description}" FORCE)
  else()
    set(${ty_config}
        OFF
        CACHE BOOL "${description}" FORCE)
  endif()
endmacro()
