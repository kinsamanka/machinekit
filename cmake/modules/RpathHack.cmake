# this is a hack to allow RUN_IN_PLACE on the build directory
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/mk_rip.c "")
add_library(mk_rip SHARED ${CMAKE_CURRENT_BINARY_DIR}/mk_rip.c)
set_target_properties(mk_rip PROPERTIES 
    LIBRARY_OUTPUT_DIRECTORY ${PROJECT_LIBEXEC_DIR}
    OUTPUT_NAME _rip)
foreach(_flav ${BUILD_THREAD_FLAVORS})
    _flavor_helper(${_flav})
    add_library(mk_rip.${_fname} SHARED ${CMAKE_CURRENT_BINARY_DIR}/mk_rip.c)
    set_target_properties(mk_rip.${_fname} PROPERTIES 
        LIBRARY_OUTPUT_DIRECTORY ${PROJECT_LIBEXEC_DIR}/${_fname}
        OUTPUT_NAME _rip.${_fname})
    _install_exec(mk_rip.${_fname} ${_fname})
endforeach()
_install_exec(mk_rip)

# set the RPATH for installed binaries, but only if it's not a system directory
set(_rpath "${CMAKE_INSTALL_PREFIX}/lib/machinekit")
list(FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES 
    "${CMAKE_INSTALL_PREFIX}/lib" _res)
if("${_res}" STREQUAL "-1")
   set(_rpath  ${_rpath} "${CMAKE_INSTALL_PREFIX}/lib")
endif()
