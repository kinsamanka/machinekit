add_library(emcpose OBJECT emcpose.c)
set_target_properties(emcpose PROPERTIES
    COMPILE_FLAGS -UULAPI
    COMPILE_DEFINITIONS "RTAPI;THREAD_FLAVOR_ID=0")
