configure_file("rtapi.ini.in" 
    "${PROJECT_SYSCONF_DIR}/machinekit/rtapi.ini" @ONLY)
configure_file("machinekit.ini.in" 
    "${PROJECT_SYSCONF_DIR}/machinekit/machinekit.ini" @ONLY)
configure_file("realtime.in" "realtime" @ONLY)
configure_file("halrun.in" "halrun" @ONLY)

# create exec
foreach(tool realtime halrun)
    add_custom_command(
        OUTPUT ${PROJECT_BIN_DIR}/${tool} 
        COMMAND cmake -E copy ${tool} ${PROJECT_BIN_DIR}/${tool}
        COMMAND chmod 0755 ${PROJECT_BIN_DIR}/${tool}
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${tool}
            ${CMAKE_CURRENT_SOURCE_DIR}/${tool}.in)
    add_custom_target(${tool} ALL DEPENDS ${PROJECT_BIN_DIR}/${tool})
endforeach()

# create files for installation
set(PROJECT_SYSCONF_DIR "${INSTALL_SYSCONF_DIR}")
set(PROJECT_LIBEXEC_DIR "${CMAKE_INSTALL_PREFIX}/lib/machinekit")
set(PROJECT_BINARY_DIR "${CMAKE_INSTALL_PREFIX}")
set(PROJECT_BIN_DIR "${CMAKE_INSTALL_PREFIX}/bin")

configure_file("rtapi.ini.in" "rtapi.ini.dist" @ONLY)
configure_file("machinekit.ini.in" "machinekit.ini.dist" @ONLY)
configure_file("realtime.in" "realtime.dist" @ONLY)
configure_file("halrun.in" "halrun.dist" @ONLY)

install(PROGRAMS ${CMAKE_CURRENT_BINARY_DIR}/realtime.dist 
    DESTINATION ${PROJECT_BIN_DIR}
    RENAME realtime)

install(PROGRAMS ${CMAKE_CURRENT_BINARY_DIR}/halrun.dist 
    DESTINATION ${PROJECT_BIN_DIR}
    RENAME halrun)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/rtapi.ini.dist 
    DESTINATION ${PROJECT_SYSCONF_DIR}/machinekit
    RENAME rtapi.ini)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/machinekit.ini.dist 
    DESTINATION ${PROJECT_SYSCONF_DIR}/machinekit
    RENAME machinekit.ini)
