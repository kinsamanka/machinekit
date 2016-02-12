add_executable(halstreamer streamer_usr.c)
target_link_libraries(halstreamer mkhal)

add_executable(halsampler sampler_usr.c)
target_link_libraries(halsampler mkhal)

# get local comps
file(GLOB files RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "*.comp")

unset(_gen_comp)
# generate comps
_mkconv("conv_float_s32" "float;s32;\"\";-2147483647-1;2147483647")
_mkconv("conv_float_u32" "float;u32;\"\";0;2147483647")
_mkconv("conv_bit_s32" "bit;s32;//")
_mkconv("conv_bit_u32" "bit;u32;//")
_mkconv("conv_s32_float" "s32;float;//")
_mkconv("conv_s32_bit" "s32;bit;\"\";0;1")
_mkconv("conv_s32_u32" "s32;u32;\"\";0;0")
_mkconv("conv_u32_float" "u32;float;//")
_mkconv("conv_u32_bit" "u32;bit;\"\";-1;1")
_mkconv("conv_u32_s32" "u32;s32;\"\";-1;2147483647")

unset(_gen_man)
# create manpages
foreach(file ${_gen_comp})
    get_filename_component(name ${file} NAME_WE)
    _comp_to_man(${name} ${CMAKE_CURRENT_BINARY_DIR})
endforeach()
add_custom_target(man_conv ALL DEPENDS ${_gen_man})
set(target-man ${_gen_man})

unset(_gen_man)
# create manpages
foreach(file ${files})
    get_filename_component(name ${file} NAME_WE)
    _comp_to_man(${name})
endforeach()
add_custom_target(man_components ALL DEPENDS ${_gen_man})
set(target-man ${target-man} ${_gen_man})

unset(_gen_c)
# generate c from comps
foreach(file ${_gen_comp})
    get_filename_component(name ${file} NAME_WE)
    _comp_to_c(${name} ${CMAKE_CURRENT_BINARY_DIR})
endforeach()

# generate c from comps
foreach(file ${files})
    get_filename_component(name ${file} NAME_WE)
    _comp_to_c(${name})
endforeach()

unset(target-exec)
# create targets from generated c files
foreach(file ${_gen_c})
    get_filename_component(name ${file} NAME_WE)
    _to_rtlib(${name} ${file})
endforeach()

set(CMP_SRC
    boss_plc
    counter
    delayline
    encoder
    encoder_ratio
    lcd
    matrix_kb
    modmath
    mux_generic
    pwmgen
    sampler
    siggen
    sim_encoder
    stepgen
    streamer
    supply
    threads
    watchdog)

foreach(file ${CMP_SRC})
    _to_rtlib(${file} ${file}.c)
endforeach()

if(WITH_TARGET_PLATFORM_BEAGLEBONE)
    set(SRC hal_pru hal_prudebug)
    foreach(file ${SRC})
        set(_src ${file}.c $<TARGET_OBJECTS:prussdrv>)
        _to_rtlib(${file} ${_src})
    endforeach()
    _to_rtlib(pepper pepper.c)
endif()

set(target halstreamer halsampler)
_install("${target}")
_install_exec("${target-exec}")
_install_man("${target-man}")
