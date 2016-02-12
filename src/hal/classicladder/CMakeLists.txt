set(RT_SRC
    arithm_eval.c
    arrays.c
    calc.c
    calc_sequential.c
    calc_sequential_rt.c
    manager.c
    module_hal.c
    symbols.c
    vars_access.c)

set(SRC
    arithm_eval.c
    arrays.c
    calc.c
    calc_sequential.c
    classicladder.c
    classicladder_gtk.c
    config.c
    config_gtk.c
    drawing.c
    drawing_sequential.c
    edit.c
    edit_gtk.c
    edit_sequential.c
    editproperties_gtk.c
    emc_mods.c
    files.c
    files_project.c
    files_sequential.c
    manager.c
    manager_gtk.c
    protocol_modbus_master.c
    protocol_modbus_slave.c
    serial_linux.c
    socket_modbus_master.c
    socket_server.c
    spy_vars_gtk.c
    symbols.c
    symbols_gtk.c
    vars_access.c
    vars_names.c)

unset(target-exec)
_to_rtlib(classicladder_rt ${RT_SRC})

add_executable(classicladder ${SRC})
target_link_libraries(classicladder mkhal ${GTK2_LIBRARIES})

set_property(TARGET classicladder_rt classicladder APPEND PROPERTY
    COMPILE_DEFINITIONS SEQUENTIAL_SUPPORT HAL_SUPPORT DYNAMIC_PLCSIZE 
        RT_SUPPORT OLD_TIMERS_MONOS_SUPPORT MODBUS_IO_MASTER)

set_property(TARGET classicladder APPEND PROPERTY 
    COMPILE_DEFINITIONS GTK_INTERFACE GTK2)
set_property(TARGET classicladder APPEND PROPERTY 
    INCLUDE_DIRECTORIES "${GTK2_INCLUDE_DIRS}")

_install(classicladder)
_install_exec(${target-exec})
