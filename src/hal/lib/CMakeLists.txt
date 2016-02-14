set(HALLIBSRCS
    hal_alias.c
    hal_comp.c
    hal_funct.c
    hal_group.c
    hal_instance.c
    hal_lib.c
    hal_memory.c
    hal_misc.c
    hal_param.c
    hal_pin.c
    hal_procfs.c
    hal_rcomp.c
    hal_ring.c
    hal_signal.c
    hal_thread.c
    hal_vtable.c)

foreach(_flav ${BUILD_THREAD_FLAVORS})
    _flavor_helper(${_flav})
    add_library(hal_lib_${_fname} SHARED ${HALLIBSRCS} 
        $<TARGET_OBJECTS:rtapi_heap>)
    set_target_properties(hal_lib_${_fname} PROPERTIES 
        COMPILE_DEFINITIONS "RTAPI;THREAD_FLAVOR_ID=${RTAPI_${_FLAV}_ID}"
        COMPILE_FLAGS -UULAPI
        LIBRARY_OUTPUT_DIRECTORY ${PROJECT_LIBEXEC_DIR}/${_fname}
        OUTPUT_NAME "hal_lib"
        PREFIX "")
    _install_exec(hal_lib_${_fname} ${_fname})
endforeach()

add_library(mkhal SHARED ${HALLIBSRCS} hal_iter.c halpb.cc
    $<TARGET_OBJECTS:inifile> $<TARGET_OBJECTS:shmdrvapi>
    $<TARGET_OBJECTS:ulapi_autoload> $<TARGET_OBJECTS:rtapi_compat>
    $<TARGET_OBJECTS:rtapi_support> $<TARGET_OBJECTS:rtapi_heap>)
target_link_libraries(mkhal mk-pb2++ ${CMAKE_DL_LIBS} rt)

_install(mkhal)
