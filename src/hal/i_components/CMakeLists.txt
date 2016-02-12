file(GLOB files RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "*.icomp")

unset(_gen_c)
# generate c from comps
foreach(file ${files})
    get_filename_component(name ${file} NAME_WE)
    _icomp_to_c(${name})
endforeach()

unset(target-exec)
# create targets from generated c files
foreach(file ${_gen_c})
    get_filename_component(name ${file} NAME_WE)
    _to_rtlib(${name} ${file})
endforeach()

unset(_gen_man)
# create manpages
foreach(file ${files})
    get_filename_component(name ${file} NAME_WE)
    _icomp_to_man(${name})
endforeach()
add_custom_target(man_i_components ALL DEPENDS ${_gen_man})

_install_exec("${target-exec}")
_install_man("${_gen_man}")
