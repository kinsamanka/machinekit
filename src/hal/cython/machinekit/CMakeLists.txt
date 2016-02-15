include_directories(${PYTHON_INCLUDE_DIRS})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})

# fix rpath to enable RIP on build dir
SET(CMAKE_SKIP_BUILD_RPATH  FALSE)
SET(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE) 
SET(CMAKE_INSTALL_RPATH "${_rpath}")
SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

set(CY_SRC hal rtapi compat shmcommon)

set(sdir ${CMAKE_SOURCE_DIR}/lib/python/machinekit)
set(deps ${sdir}/halfile.py ${sdir}/launcher.py ${sdir}/service.py)
set(stamp ${CMAKE_CURRENT_BINARY_DIR}/timestamp)
add_custom_command(OUTPUT ${stamp}
    COMMAND ${CMAKE_COMMAND} -E touch ${stamp}
    COMMAND cp ${deps} ${PROJECT_PYTHON_DIR}/machinekit/
    COMMAND cp ${deps} ${CMAKE_CURRENT_BINARY_DIR}/
    DEPENDS ${deps})

set(init ${PROJECT_PYTHON_DIR}/machinekit/__init__.py)
add_custom_command(OUTPUT ${init}
    COMMAND ${CMAKE_COMMAND} -E touch ${init}
    COMMAND ${CMAKE_COMMAND} -E touch __init__.py)

set(PWD ${CMAKE_CURRENT_BINARY_DIR})
foreach(file ${CY_SRC})
    add_custom_command(
        OUTPUT  ${PWD}/${file}.c
        COMMAND ${CYTHON} -o ${PWD}/${file}.c ${file}.pyx
        DEPENDS ${file}.pyx ${file}.pxd ${init} ${stamp}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "Generate C files from ${file}.pyx")
endforeach()

add_library(cy_hal SHARED ${PWD}/hal.c $<TARGET_OBJECTS:halcmd_rtapiapp>)
target_link_libraries(cy_hal mkhal mtalk mk_rip)
set_target_properties(cy_hal PROPERTIES
    OUTPUT_NAME "hal"
    PREFIX "")

add_library(cy_rtapi SHARED ${PWD}/rtapi.c $<TARGET_OBJECTS:halcmd_rtapiapp>)
target_link_libraries(cy_rtapi mkhal mtalk mk-pb2++ mk_rip)
set_target_properties(cy_rtapi PROPERTIES
    OUTPUT_NAME "rtapi"
    PREFIX "")

add_library(cy_compat SHARED ${PWD}/compat.c)
target_link_libraries(cy_compat mkhal mk_rip)
set_target_properties(cy_compat PROPERTIES
    OUTPUT_NAME "compat"
    PREFIX "")

add_library(cy_shmcommon SHARED ${PWD}/shmcommon.c $<TARGET_OBJECTS:shmdrvapi>)
target_link_libraries(cy_shmcommon mk_rip)
set_target_properties(cy_shmcommon PROPERTIES
    OUTPUT_NAME "shmcommon"
    PREFIX "")

# copy files to local python dir
add_custom_target(mk_cy ALL
    COMMAND cp $<TARGET_FILE:cy_hal> $<TARGET_FILE:cy_rtapi> 
        $<TARGET_FILE:cy_compat> $<TARGET_FILE:cy_shmcommon>
        ${PROJECT_PYTHON_DIR}/machinekit
    DEPENDS cy_hal cy_rtapi cy_compat cy_shmcommon)

configure_file("config.py.in" "${PROJECT_PYTHON_DIR}/machinekit/config.py" @ONLY)

# create files for installation
set(PROJECT_SYSCONF_DIR "${INSTALL_SYSCONF_DIR}")
set(PROJECT_LIBEXEC_DIR "${CMAKE_INSTALL_PREFIX}/lib/machinekit")
set(PROJECT_BINARY_DIR "${CMAKE_INSTALL_PREFIX}")
set(PROJECT_BIN_DIR "${CMAKE_INSTALL_PREFIX}/bin")

configure_file("config.py.in" "config.py" @ONLY)
