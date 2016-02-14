add_subdirectory(mesa-hostmot2)
add_subdirectory(hal_pru_generic)

add_custom_command( 
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/pluto_step_rbf.h
    COMMAND ${PYTHON_EXECUTABLE} rbf2h.py -g
        -c "This is a component of pluto_step, a hardware step generator for emc2"
        -c "Copyright (C) 2006, 2007 Jeff Epler"
        pluto_step_firmware/pluto_step.rbf
        > ${CMAKE_CURRENT_BINARY_DIR}/pluto_step_rbf.h
    DEPENDS rbf2h.py pluto_step_firmware/pluto_step.rbf
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    VERBATIM)
add_custom_target(pluto_step_rbf
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/pluto_step_rbf.h)

add_custom_command( 
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/pluto_servo_rbf.h
    COMMAND ${PYTHON_EXECUTABLE} rbf2h.py -g
        -c "This is a component of pluto_servo, a PWM servo driver and"
        -c "quadrature counter for emc2"
        -c "Copyright (C) 2006, 2007 Jeff Epler"
        pluto_servo_firmware/pluto_servo.rbf
        > ${CMAKE_CURRENT_BINARY_DIR}/pluto_servo_rbf.h
    DEPENDS rbf2h.py pluto_servo_firmware/pluto_servo.rbf
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    VERBATIM)
add_custom_target(pluto_servo_rbf
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/pluto_servo_rbf.h)

set(COMP_SRC mesa_7i65 mesa_uart pcl720 pluto_servo pluto_step serport)

unset(_gen_c)
# generate c from comps
foreach(file ${COMP_SRC})
    _comp_to_c(${file})
endforeach()

unset(target-exec)
# create targets from generated c files
foreach(file ${_gen_c})
    get_filename_component(name ${file} NAME_WE)
    _to_rtlib(${name} ${file})
endforeach()

foreach(_flav ${BUILD_THREAD_FLAVORS})
    _flavor_helper(${_flav})
    add_dependencies(pluto_servo.${_fname} pluto_servo_rbf)
    add_dependencies(pluto_step.${_fname} pluto_step_rbf)
endforeach()

unset(_gen_man)
# create manpages
foreach(file ${COMP_SRC})
    _comp_to_man(${file})
endforeach()

add_custom_target(man_drivers ALL DEPENDS ${_gen_man})

_to_rtlib(hal_parport hal_parport.c)
_to_rtlib(pci_8255 pci_8255.c)
_to_rtlib(hal_tiro hal_tiro.c)
_to_rtlib(hal_stg hal_stg.c)
_to_rtlib(hal_vti hal_vti.c)
_to_rtlib(hal_motenc hal_motenc.c)
_to_rtlib(hal_ax5214h hal_ax5214h.c)
_to_rtlib(hal_speaker hal_speaker.c)
_to_rtlib(hal_skeleton hal_skeleton.c)
_to_rtlib(gpiomap hal_gpiomap.c)
_to_rtlib(gpiouse hal_gpiouse.c)
_to_rtlib(probe_parport probe_parport.c)

if(WITH_TARGET_PLATFORM_RASPBERRY)
    set(SRC hal_gpio.c cpuinfo.c)
    _to_rtlib(hal_gpio ${SRC})
    _to_rtlib(hal_spi hal_spi.c)
endif()

if(WITH_TARGET_PLATFORM_BEAGLEBONE)
    _to_rtlib(hal_bb_gpio hal_bb_gpio.c)
    _to_rtlib(hal_arm335xQEP hal_arm335xQEP.c)
endif()

if(WITH_TARGET_PLATFORM_ZEDBOARD)
    _to_rtlib(hal_zed_gpio hal_zed_gpio.c)
    _to_rtlib(hal_zed_can hal_zed_can.c)
endif()

_install_exec("${target-exec}")
_install_man("${_gen_man}")
