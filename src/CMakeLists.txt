set(with_protobuf "define")
set(with_boost "define")
set(with_czmq "define")
set(with_avahi "define")
set(with_jansson "define")
set(with_lws "define")
set(with_ssl "define")
set(with_uriparser "define")
set(with_uuid "define")

if(WITH_USERMODE_PCI)
    pkg_check_modules(UDEV REQUIRED libudev)
    set(with_usermode_pci "define")
else()
    set(with_usermode_pci "undef")
endif()

set(RTAPI_POSIX_ID 0)
set(RTAPI_POSIX_NAME "posix")
set(POSIX_THREADS_SOURCE rt-preempt.c)
set(RTAPI_RT_PREEMPT_ID 1)
set(RTAPI_RT_PREEMPT_NAME "rt-preempt")
set(RT_PREEMPT_THREADS_SOURCE rt-preempt.c)
set(RTAPI_XENOMAI_ID 2)
set(RTAPI_XENOMAI_NAME "xenomai")
set(XENOMAI_THREADS_SOURCE xenomai.c)

# create and populate include dir
include(LinkIncludes)
include(RpathHack)

include_directories(${INCLUDE_DIR})
include_directories(${INCLUDE_DIR}/proto)

set(CMAKE_C_FLAGS 
    "${CMAKE_C_FLAGS} -fPIC -fwrapv -fno-strict-overflow -std=gnu99 -fgnu89-inline")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")

# enable runtime comparison of GIT_CONFIG_SHA (config.h) and GIT_BUILD_SHA
find_program(GIT git)
if(GIT)
    execute_process(COMMAND git rev-parse --short HEAD
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        OUTPUT_VARIABLE _out
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE)
    if(NOT _out)
        set(_out "non_git_repo")
    else()
        execute_process(COMMAND git rev-parse --abbrev-ref HEAD
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            OUTPUT_VARIABLE _branch
            ERROR_QUIET
            OUTPUT_STRIP_TRAILING_WHITESPACE)
    endif()
else()
    set(_out "no_git_found")
endif()
if(NOT _branch)
    set(_branch "none")
endif()

set(GIT_VERSION "v${Machinekit_VERSION_MAJOR}.${Machinekit_VERSION_MINOR}~${_branch}~${_out}")
set(GIT_CONFIG_SHA "${_out}")

if("${CMAKE_INSTALL_PREFIX}" STREQUAL "/usr")
    add_definitions(-DEMC2_SYSTEM_CONFIG_DIR=\"/etc/machinekit\")
else()
    add_definitions(-DEMC2_SYSTEM_CONFIG_DIR=\"${CMAKE_INSTALL_PREFIX}/etc/machinekit\")
endif()

add_definitions(-DULAPI)
set(NPB_DEFINITIONS PB_FIELD_32BIT PB_SYSTEM_HEADER=<pb-linuxcnc.h>)

add_subdirectory(machinetalk)
add_subdirectory(libnml)
add_subdirectory(rtapi)
add_subdirectory(hal)
add_subdirectory(emc)

add_dependencies(rtapi_app pb_gen_files)
foreach(_flav ${BUILD_THREAD_FLAVORS})
    _flavor_helper(${_flav})
    add_dependencies(pbring.${_fname} npb_gen_files)
    add_dependencies(pbmsgs.${_fname} npb_gen_files)
    add_dependencies(ringload.${_fname} npb_gen_files)
endforeach()

# create needed directories
file(MAKE_DIRECTORY ${PROJECT_MAN_DIR}/man1)
file(MAKE_DIRECTORY ${PROJECT_MAN_DIR}/man3)
file(MAKE_DIRECTORY ${PROJECT_MAN_DIR}/man9)
file(MAKE_DIRECTORY ${PROJECT_SYSCONF_DIR})

# create config.h
configure_file(
    "${PROJECT_SOURCE_DIR}/src/config.h.in"
    "${PROJECT_BINARY_DIR}/include/config.h"
    @ONLY)
