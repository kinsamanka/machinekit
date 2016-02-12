option(WITH_USERMODE_PCI "Build PCI drivers with usermode PCI support" ON)
option(WITH_XENOMAI "Build Xenomai userland threads" ON)

find_program(XENO_CONFIG xeno-config)
if(NOT XENO_CONFIG OR NOT WITH_XENOMAI)
    message(WARNING "xenomai flavor disabled")
    set(BUILD_THREAD_FLAVORS posix rt_preempt)
    set(with_xenomai "undef")
    unset(XENOMAI_SKIN)
else()
    set(BUILD_THREAD_FLAVORS posix rt_preempt xenomai)
    set(XENOMAI_SKIN native)
    set(with_xenomai "define")
    execute_process(COMMAND ${XENO_CONFIG} --skin ${XENOMAI_SKIN} --cflags
                    OUTPUT_VARIABLE XENO_CFLAGS
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    execute_process(COMMAND ${XENO_CONFIG} --skin ${XENOMAI_SKIN} --ldflags
                    OUTPUT_VARIABLE XENO_LDFLAGS
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()
