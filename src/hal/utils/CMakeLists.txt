set(HALCMD_SRCS 
    halcmd.c
    halcmd_commands.c
    halcmd_main.c
    halcmd_rtapiapp.cc 
    halcmd_completion.c)

add_library(halcmd_rtapiapp OBJECT halcmd_rtapiapp.cc)

add_executable(halcmd ${HALCMD_SRCS})
target_link_libraries(halcmd mkini mkhal mk-pb2++ mtalk rtapi_math readline)

add_executable(pci_write pci_write.c upci.c)
add_executable(pci_read pci_read.c upci.c)

separate_arguments(PY_CMDS UNIX_COMMAND 
    "-c 'import sys\; compile(open(sys.argv[1]).read(), sys.argv[1], \"exec\")'")
separate_arguments(SED_CMDS UNIX_COMMAND "'1s-^#!.*-#!${PYTHON_EXECUTABLE}-'")

foreach(util comp instcomp)
    set(src ${CMAKE_CURRENT_SOURCE_DIR}/${util}.g)
    add_custom_command( 
        OUTPUT ${PROJECT_BINARY_DIR}/bin/${util}
        COMMAND ${YAPPS} ${src} ${util}.py
        COMMAND ${PYTHON_EXECUTABLE} ${PY_CMDS} ${util}.py
        COMMAND sed ${SED_CMDS} ${util}.py > ${PROJECT_BINARY_DIR}/bin/${util}
        COMMAND chmod +x ${PROJECT_BINARY_DIR}/bin/${util}
        DEPENDS ${src}
        COMMENT "Creating ${util}"
        VERBATIM)
    add_custom_target(${util}_bin DEPENDS ${PROJECT_BINARY_DIR}/bin/${util})
    set(PYHAL_UTILS ${PYHAL_UTILS} ${PROJECT_BINARY_DIR}/bin/${util})
endforeach()
add_custom_target(pyhal_utils ALL DEPENDS ${PYHAL_UTILS})

add_executable(halmeter meter.c miscgtk.c)
set_property(TARGET halmeter APPEND PROPERTY 
    INCLUDE_DIRECTORIES "${GTK2_INCLUDE_DIRS}")
target_link_libraries(halmeter mkhal ${GTK2_LIBRARIES})

set(HALSCOPE_SRCS
    scope.c
    scope_horiz.c
    scope_vert.c
    scope_trig.c
    scope_disp.c
    scope_files.c
    miscgtk.c)

add_executable(halscope ${HALSCOPE_SRCS})
set_property(TARGET halscope APPEND PROPERTY
    INCLUDE_DIRECTORIES "${GTK2_INCLUDE_DIRS}")
target_link_libraries(halscope mkhal rtapi_math ${GTK2_LIBRARIES})

_to_rtlib(scope_rt scope_rt.c)

# fixme
# set_property(GLOBAL APPEND PROPERTY target-dev pyhal_utils)
set(target halcmd pci_write pci_read halmeter halscope)
_install("${target}")
