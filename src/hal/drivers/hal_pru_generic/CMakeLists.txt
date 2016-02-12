unset(target-exec)

if(WITH_TARGET_PLATFORM_BEAGLEBONE)
    set(SRC hal_pru_generic.c pwmgen.c stepgen.c encoder.c
        $<TARGET_OBJECTS:prussdrv>)
        
    _to_rtlib(hal_pru_generic ${SRC})
    _to_rtlib(pepper pepper.c)
    _install_exec("${target-exec}")
endif()
