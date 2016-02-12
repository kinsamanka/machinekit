add_library(cubic OBJECT cubic.c)
set_target_properties(cubic PROPERTIES
    COMPILE_FLAGS -UULAPI
    COMPILE_DEFINITIONS "RTAPI;THREAD_FLAVOR_ID=0")

unset(target-exec)

_to_rtlib(trivkins trivkins.c)
_to_rtlib(5axiskins 5axiskins.c)
_to_rtlib(maxkins maxkins.c)
_to_rtlib(gantrykins gantrykins.c)
_to_rtlib(rotatekins rotatekins.c)
_to_rtlib(tripodkins tripodkins.c)
_to_rtlib(lineardeltakins lineardeltakins.c)

set(SRC genhexkins pumakins scarakins)
foreach(file ${SRC})
    set(_src ${file}.c $<TARGET_OBJECTS:_posemath>)
    _to_rtlib(${file} ${_src})
endforeach()

set(_src genserkins.c $<TARGET_OBJECTS:gomath>)
_to_rtlib(genserkins ${_src})

_install_exec("${target-exec}")
