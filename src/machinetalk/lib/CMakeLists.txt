set(LIBMTALK_SRCS 
    czmq-watch.c
	inihelp.cc
    json2pb.cc
    ll_zeroconf_register.cc
    mk_backtrace.c
	mk_service.cc
    mk_zeroconf.cc
    pbutil.cc
    setup_signals.c
	syslog_async.c
	zeroconf_resolve.cc
)

add_library(mtalk SHARED ${LIBMTALK_SRCS})
set_target_properties(mtalk PROPERTIES COMPILE_FLAGS
    "${AVAHI_CFLAGS} ${CZMQ_CFLAGS} ${JANSSON_CFLAGS} ${UUID_CFLAGS}")
target_link_libraries(mtalk mk-pb2++ mkini
    ${AVAHI_LIBRARIES} ${CZMQ_LIBRARIES} ${JANSSON_LIBRARIES} ${UUID_LIBRARIES})

add_executable(zres zeroconf_resolve_test.cc)
set_target_properties(zres PROPERTIES COMPILE_FLAGS "-std=c++0x")
target_link_libraries(zres mtalk mk-pb2++ mkini)# ${AVAHI_LIBRARIES}

set(target mtalk zres)
_install("${target}")
