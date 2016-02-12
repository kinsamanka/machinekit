add_subdirectory(rtapi_math)
add_subdirectory(shmdrv)

set(XXAPI_COMMON_SRCS
    rtapi_common.c
    rtapi_task.c
    rtapi_shmem.c
    rtapi_time.c
    rtapi_exception.c)

add_library(rtapi_heap OBJECT rtapi_heap.c)
add_library(rtapi_app OBJECT rtapi_app.cc)
add_library(rtapi_compat OBJECT rtapi_compat.c)
add_library(rtapi_support OBJECT rtapi_support.c rtapi_hexdump.c)
add_library(ulapi_autoload OBJECT ulapi_autoload.c)

# GIT_BUILD_SHA
if(GIT)
    execute_process(COMMAND git rev-parse --short HEAD
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        OUTPUT_VARIABLE _out
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE)
    if(NOT _out)
        set(_out "non_git_repo")
    endif()
else()
    set(_out "no_git_found")
endif()

add_executable(rtapi_msgd rtapi_msgd.cc 
    $<TARGET_OBJECTS:rtapi_compat> $<TARGET_OBJECTS:rtapi_heap>)
set_target_properties(rtapi_msgd PROPERTIES
    COMPILE_DEFINITIONS 
        "GIT_BUILD_SHA=\"${_out}\";LWS_LIBRARY_VERSION=\"${LWS_VERSION}\""
    RUNTIME_OUTPUT_DIRECTORY ${PROJECT_LIBEXEC_DIR})
target_link_libraries(rtapi_msgd mtalk mk-pb2++ mkini mkshm)

add_executable(flavor flavor.c $<TARGET_OBJECTS:rtapi_compat>)
set_target_properties(flavor PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${PROJECT_LIBEXEC_DIR})
target_link_libraries(flavor mkini mkshm)

set(RTAPI_SRC ${XXAPI_COMMON_SRCS} 
    rtapi_main.c rtapi_support.c rtapi_hexdump.c rtapi_compat.c
    $<TARGET_OBJECTS:rtapi_heap> $<TARGET_OBJECTS:nanopb>)

set(cflags "-UULAPI")
if(WITH_USERMODE_PCI)
    set(RTAPI_SRC ${RTAPI_SRC} rtapi_pci.c)
    if(UDEV_CFLAGS)
        set(cflags "${cflags} ${UDEV_CFLAGS}")
    endif()
endif()

# this is a hack to allow RUN_IN_PLACE on the build directory
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/mk_rip.c "")
add_library(mk_rip SHARED ${CMAKE_CURRENT_BINARY_DIR}/mk_rip.c)
set_target_properties(mk_rip PROPERTIES 
    LIBRARY_OUTPUT_DIRECTORY ${PROJECT_LIBEXEC_DIR})

# set the RPATH for installed binaries, but only if it's not a system directory
set(_rpath "${CMAKE_INSTALL_PREFIX}/lib/machinekit")
list(FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES "${CMAKE_INSTALL_PREFIX}/lib" _res)
if("${_res}" STREQUAL "-1")
   set(_rpath  ${_rpath} "${CMAKE_INSTALL_PREFIX}/lib")
endif()

foreach(_flav ${BUILD_THREAD_FLAVORS})
    _flavor_helper(${_flav})

    add_library(ulapi-${_fname} SHARED ${XXAPI_COMMON_SRCS}
        ulapi_main.c ${${_FLAV}_THREADS_SOURCE}
        $<TARGET_OBJECTS:rtapi_heap> $<TARGET_OBJECTS:rtapi_support>)
    set_target_properties(ulapi-${_fname} PROPERTIES 
        COMPILE_DEFINITIONS "THREAD_FLAVOR_ID=${RTAPI_${_FLAV}_ID}"
        LIBRARY_OUTPUT_DIRECTORY ${PROJECT_LIBEXEC_DIR}
        PREFIX "")
    target_link_libraries(ulapi-${_fname} mkshm mkhal)
    if(${_flav} STREQUAL xenomai)
        set_target_properties(ulapi-${_fname} PROPERTIES 
            COMPILE_FLAGS ${XENO_CFLAGS})
        set(cflags "${cflags} ${XENO_CFLAGS}")
    endif()

    add_library(rtapi_${_fname} SHARED ${RTAPI_SRC} ${${_FLAV}_THREADS_SOURCE})
    set_target_properties(rtapi_${_fname} PROPERTIES 
        COMPILE_DEFINITIONS "RTAPI;THREAD_FLAVOR_ID=${RTAPI_${_FLAV}_ID}"
        COMPILE_FLAGS "${cflags}"
        LIBRARY_OUTPUT_DIRECTORY ${PROJECT_LIBEXEC_DIR}/${_fname}
        OUTPUT_NAME "rtapi"
        PREFIX "")
    if(${_flav} STREQUAL xenomai)
        set_target_properties(rtapi_${_fname} PROPERTIES LINK_FLAGS ${XENO_LDFLAGS})
    endif()
    if(WITH_USERMODE_PCI)
        target_link_libraries(rtapi_${_fname} ${UDEV_LIBRARIES})
    endif()
    
    add_executable(rtapi_app_${_fname} $<TARGET_OBJECTS:rtapi_app>
        $<TARGET_OBJECTS:rtapi_compat> $<TARGET_OBJECTS:rtapi_support>)
    set_target_properties(rtapi_app_${_fname} PROPERTIES
        BUILD_WITH_INSTALL_RPATH FALSE
        INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib/machinekit/${_fname};${_rpath}"
        INSTALL_RPATH_USE_LINK_PATH TRUE
        COMPILE_DEFINITIONS RTAPI
        COMPILE_FLAGS -UULAPI
        RUNTIME_OUTPUT_DIRECTORY ${PROJECT_LIBEXEC_DIR})
    # link with rtapi_${_fname} to allow RUN_IN_PLACE
    target_link_libraries(rtapi_app_${_fname} mkini mkshm mtalk rtapi_math 
        mk-pb2++ ${CMAKE_DL_LIBS} rtapi_${_fname} mk_rip)
    set(SETUID_DEPS ${SETUID_DEPS} rtapi_app_${_fname})

    _install_exec(rtapi_${_fname} ${_fname})
    _install_exec_setuid(rtapi_app_${_fname})
    set(target-exec ${target-exec} ulapi-${_fname})
endforeach()

add_custom_target(setuid 
    COMMAND chown 0:0 ${SETUID_DEPS}
    COMMAND chmod 4755 ${SETUID_DEPS}
    DEPENDS ${SETUID_DEPS}
    WORKING_DIRECTORY ${PROJECT_LIBEXEC_DIR}
    VERBATIM)

install(FILES rsyslogd-linuxcnc.conf
    DESTINATION ${INSTALL_SYSCONF_DIR}/rsyslog.d
    RENAME linuxcnc.conf)

set(target-exec ${target-exec} rtapi_msgd flavor mk_rip)
_install_exec("${target-exec}")
