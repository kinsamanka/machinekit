add_library(shmdrvapi OBJECT shmdrvapi.c)

add_library(mkshm SHARED $<TARGET_OBJECTS:shmdrvapi>)
target_link_libraries(mkshm rt)

_install(mkshm)

install(FILES shmdrv.rules
    DESTINATION ${INSTALL_SYSCONF_DIR}/udev/rules.d
    RENAME 50-shmdrv.rules)

install(FILES limits.d-machinekit.conf
    DESTINATION ${INSTALL_SYSCONF_DIR}/security/limits.d
    RENAME machinekit.conf)
