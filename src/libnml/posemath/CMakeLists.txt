add_library(_posemath OBJECT _posemath.c sincos.c)
set_target_properties(_posemath PROPERTIES
    COMPILE_FLAGS -UULAPI
    COMPILE_DEFINITIONS "RTAPI;THREAD_FLAVOR_ID=0")

add_library(gomath OBJECT gomath.c sincos.c)
set_target_properties(gomath PROPERTIES
    COMPILE_FLAGS -UULAPI
    COMPILE_DEFINITIONS "RTAPI;THREAD_FLAVOR_ID=0")
