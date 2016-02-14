#! _mkconv : this macro creates conv_IN_OUT.comp from conv.comp.in 
#
# this calls the mkconv.sh script with the required parameters
#
# the list of generated comp files ${_gen_comp} is then updated after the macro ends
#
# \arg:NAME name of the output file
# \arg:ARGS list of arguments needed by mkconv.sh
#
macro(_mkconv NAME ARGS)
    set(_args "${ARGS}")
    set(_comp "${CMAKE_CURRENT_BINARY_DIR}/${NAME}.comp")
    add_custom_command(
        OUTPUT ${_comp}
        COMMAND bash mkconv.sh ${_args} < conv.comp.in > ${_comp}
        DEPENDS mkconv.sh conv.comp.in comp_bin
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
    set(_gen_comp ${_gen_comp} ${_comp})
endmacro()

#! _comp_to_c : this macro generates c source files from comp file
#
# the list of generated c files ${_gen_c} is updated after the macro ends
#
# \arg:NAME comp src file without the extension
# \arg:DIR Optional, source directory
#
macro(_comp_to_c NAME)
    if(NOT ${ARGV1})
        set(_wdir ${ARGV1})
    else()
        set(_wdir  ${CMAKE_CURRENT_SOURCE_DIR})
    endif()
    set(_c "${CMAKE_CURRENT_BINARY_DIR}/${NAME}.c")
    add_custom_command(
        OUTPUT ${_c}
        COMMAND ${PROJECT_BIN_DIR}/comp 
            --require-license -o ${_c} ${NAME}.comp
        DEPENDS ${_wdir}/${NAME}.comp comp_bin
        WORKING_DIRECTORY ${_wdir})
    set(_gen_c ${_gen_c} ${_c})
endmacro()

#! _comp_to_man : this macro generates manpages from comp file
#
# the list of generated manpages ${_gen_man} is updated after the macro ends
#
# \arg:NAME comp src file without the extension
# \arg:DIR Optional, source directory
#
macro(_comp_to_man NAME)
    if(NOT ${ARGV1})
        set(_wdir ${ARGV1})
    else()
        set(_wdir  ${CMAKE_CURRENT_SOURCE_DIR})
    endif()
    set(_man "${PROJECT_MAN_DIR}/man9/${NAME}.9comp")
    add_custom_command(
        OUTPUT ${_man}
        COMMAND ${PROJECT_BIN_DIR}/comp 
            --document -o ${_man} ${NAME}.comp
        DEPENDS ${_wdir}/${NAME}.comp comp_bin
        WORKING_DIRECTORY ${_wdir})
    set(_gen_man ${_gen_man} ${_man})
endmacro()

#! _icomp_to_c : this macro generates c source files from icomp file
#
# the list of generated c files ${_gen_c} is updated after the macro ends
#
# \arg:NAME icomp src file without the extension
# \arg:DIR Optional, source directory
#
macro(_icomp_to_c NAME)
    if(NOT ${ARGV1})
        set(_wdir ${ARGV1})
    else()
        set(_wdir  ${CMAKE_CURRENT_SOURCE_DIR})
    endif()
    set(_c "${CMAKE_CURRENT_BINARY_DIR}/${NAME}.c")
    add_custom_command(
        OUTPUT ${_c}
        COMMAND ${PROJECT_BIN_DIR}/instcomp 
            --require-license -o ${_c} ${NAME}.icomp
        DEPENDS ${_wdir}/${NAME}.icomp instcomp_bin
        WORKING_DIRECTORY ${_wdir})
    set(_gen_c ${_gen_c} ${_c})
endmacro()

#! _icomp_to_man : this macro generates manpages from icomp file
#
# the list of generated manpages ${_gen_man} is updated after the macro ends
#
# \arg:NAME comp src file without the extension
# \arg:DIR Optional, source directory
#
macro(_icomp_to_man NAME)
    if(NOT ${ARGV1})
        set(_wdir ${ARGV1})
    else()
        set(_wdir  ${CMAKE_CURRENT_SOURCE_DIR})
    endif()
    set(_man "${PROJECT_MAN_DIR}/man9/${NAME}.9comp")
    add_custom_command(
        OUTPUT ${_man}
        COMMAND ${PROJECT_BIN_DIR}/instcomp 
            --document -o ${_man} ${NAME}.icomp
        DEPENDS ${_wdir}/${NAME}.icomp instcomp_bin
        WORKING_DIRECTORY ${_wdir})
    set(_gen_man ${_gen_man} ${_man})
endmacro()

#! _flavor_helper : helper macro
#
# sets FLAV to uppercase and stores in _FLAV
# _fname is the defined flavor name
#
# \arg:FLAV flavor name
#
macro(_flavor_helper FLAV)
    string(TOUPPER ${FLAV} _FLAV)
    set(_fname ${RTAPI_${_FLAV}_NAME})
endmacro()

#! _to_rtlib : this macro generates an rt library for all flavors
#
# \arg:NAME library name
# \arg:SRCS sources
# \arg:CFLAGS Optional, additional flags
#
macro(_to_rtlib NAME SRCS)
    foreach(_flav ${BUILD_THREAD_FLAVORS})
        _flavor_helper(${_flav})

        set(_cflags -UULAPI)
        if(${ARGV1})
            set(_cflags -UULAPI ${ARGV1})
        endif()
        add_library(${NAME}~${_fname} SHARED ${SRCS})
        set_target_properties(${NAME}~${_fname} PROPERTIES 
            COMPILE_DEFINITIONS "RTAPI;THREAD_FLAVOR_ID=0"
            COMPILE_FLAGS ${_cflags}
            LIBRARY_OUTPUT_DIRECTORY ${PROJECT_LIBEXEC_DIR}/${_fname}
            OUTPUT_NAME ${NAME}
            PREFIX "")
        # set(target-exec ${target-exec} ${NAME}_${_fname}_)
        set(_lib_dest lib/machinekit/${_fname})
        install(TARGETS ${NAME}~${_fname}
            LIBRARY DESTINATION ${_lib_dest})
    endforeach()
endmacro()

macro(_install SRC)
    install(TARGETS ${SRC} 
    	DESTINATION bin
    	LIBRARY DESTINATION lib)
endmacro()

macro(_install_exec SRC)
    set(_lib_dest lib/machinekit)
    if(NOT ${ARGV1})
        set(_lib_dest lib/machinekit/${ARGV1})
    endif()    
    install(TARGETS ${SRC} 
    	DESTINATION lib/machinekit
        LIBRARY DESTINATION ${_lib_dest})
endmacro()

macro(_install_exec_flavor SRC)
    foreach(_flav ${BUILD_THREAD_FLAVORS})
        _flavor_helper(${_flav})

        set(_lib_dest lib/machinekit/${_fname})
        install(TARGETS ${SRC}_${_fname}_
        	DESTINATION lib/machinekit
            LIBRARY DESTINATION ${_lib_dest})
        endforeach()
endmacro()

macro(_install_exec_setuid SRC)
    set(_lib_dest lib/machinekit)
    if(NOT ${ARGV1})
        set(_lib_dest lib/machinekit/${ARGV1})
    endif()    
    install(TARGETS ${SRC} 
    	DESTINATION lib/machinekit
        PERMISSIONS SETUID
            OWNER_WRITE OWNER_READ OWNER_EXECUTE
            GROUP_READ GROUP_EXECUTE
            WORLD_EXECUTE WORLD_READ
        LIBRARY DESTINATION ${_lib_dest})
endmacro()

macro(_install_man SRC)
    install(FILES ${SRC} 
    	DESTINATION ${CMAKE_INSTALL_PREFIX}/man/man9)
endmacro()

macro(_install_script SRC)
    install(PROGRAMS ${SRC} 
        DESTINATION ${CMAKE_INSTALL_PREFIX}/bin)
endmacro()
