set(MOTMOD_SRC motion.c command.c control.c homing.c emcmotglb.c emcmotutil.c
    stashf.c dbuf.c $<TARGET_OBJECTS:cubic> $<TARGET_OBJECTS:_posemath>)
_to_rtlib(motmod ${MOTMOD_SRC})
_install_exec(motmod)
