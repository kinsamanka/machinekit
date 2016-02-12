set(TP_SRC tc.c tcq.c tp.c tpmain.c blendmath.c spherical_arc.c
    $<TARGET_OBJECTS:emcpose> $<TARGET_OBJECTS:_posemath>)
_to_rtlib(tp ${TP_SRC})
_install_exec(tp)
