include_directories(${PYTHON_INCLUDE_DIRS})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_PYTHON_DIR}/machinekit)

set(CY_SRC hal rtapi compat shmcommon)

set(sdir ${CMAKE_SOURCE_DIR}/lib/python/machinekit)
set(deps ${sdir}/halfile.py ${sdir}/launcher.py ${sdir}/service.py)
set(stamp ${CMAKE_CURRENT_BINARY_DIR}/timestamp)
add_custom_command(OUTPUT ${stamp}
    COMMAND ${CMAKE_COMMAND} -E touch ${stamp}
    COMMAND cp ${deps} ${PROJECT_PYTHON_DIR}/machinekit/
    DEPENDS ${deps})

set(init ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/__init__.py)

add_custom_command(OUTPUT ${init}
  COMMAND ${CMAKE_COMMAND} -E touch ${init})

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
target_link_libraries(cy_hal mkhal mtalk)
set_target_properties(cy_hal PROPERTIES
    OUTPUT_NAME "hal"
    PREFIX "")

add_library(cy_rtapi SHARED ${PWD}/rtapi.c $<TARGET_OBJECTS:halcmd_rtapiapp>)
target_link_libraries(cy_rtapi mkhal mtalk mk-pb2++)
set_target_properties(cy_rtapi PROPERTIES
    OUTPUT_NAME "rtapi"
    PREFIX "")

add_library(cy_compat SHARED ${PWD}/compat.c)
target_link_libraries(cy_compat mkhal)
set_target_properties(cy_compat PROPERTIES
    OUTPUT_NAME "compat"
    PREFIX "")

add_library(cy_shmcommon SHARED ${PWD}/shmcommon.c $<TARGET_OBJECTS:shmdrvapi>)
set_target_properties(cy_shmcommon PROPERTIES
    OUTPUT_NAME "shmcommon"
    PREFIX "")

 
