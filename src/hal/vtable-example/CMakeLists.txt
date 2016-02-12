unset(target-exec)

_to_rtlib(vtuse vtuse.c)

set(SRC vtexport.c vcode.c)
_to_rtlib(vtexport ${SRC})

_install_exec("${target-exec}")
