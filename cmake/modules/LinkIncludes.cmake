# create and populate include dir
set(H_DIRS
    emc/kinematics
    emc/motion
    emc/nml_intf
    emc/tp
    hal/lib
    hal/utils
    libnml/inifile
    libnml/nml
    libnml/posemath
    machinetalk/include
    machinetalk/msgcomponents
    machinetalk/nanopb
    rtapi
    rtapi/rtapi_math
    rtapi/shmdrv)

file(MAKE_DIRECTORY ${INCLUDE_DIR}/proto)
file(MAKE_DIRECTORY ${INCLUDE_DIR}/nanopb)
file(MAKE_DIRECTORY ${INCLUDE_DIR}/userpci)
file(MAKE_DIRECTORY ${INCLUDE_DIR}/drivers/mesa-hostmot2)

file(GLOB files "${CMAKE_CURRENT_SOURCE_DIR}/machinetalk/nanopb/*.h")
foreach(file ${files})
    get_filename_component(f ${file} NAME)
    execute_process(COMMAND cmake -E create_symlink 
        ${file} ${INCLUDE_DIR}/nanopb/${f})
endforeach()

file(GLOB files "${CMAKE_CURRENT_SOURCE_DIR}/rtapi/userpci/*.h")
foreach(file ${files})
    get_filename_component(f ${file} NAME)
    execute_process(COMMAND cmake -E create_symlink 
        ${file} ${INCLUDE_DIR}/userpci/${f})
endforeach()

file(GLOB files "${CMAKE_CURRENT_SOURCE_DIR}/hal/drivers/*.h")
foreach(file ${files})
    get_filename_component(f ${file} NAME)
    execute_process(COMMAND cmake -E create_symlink 
        ${file} ${INCLUDE_DIR}/drivers/${f})
endforeach()

file(GLOB files "${CMAKE_CURRENT_SOURCE_DIR}/hal/drivers/mesa-hostmot2/*.h")
foreach(file ${files})
    get_filename_component(f ${file} NAME)
    execute_process(COMMAND cmake -E create_symlink 
        ${file} ${INCLUDE_DIR}/drivers/mesa-hostmot2/${f})
endforeach()

foreach(dir ${H_DIRS})
    file(GLOB files "${CMAKE_CURRENT_SOURCE_DIR}/${dir}/*.h"
        "${CMAKE_CURRENT_SOURCE_DIR}/${dir}/*.hh")
    foreach(file ${files})
        get_filename_component(f ${file} NAME)
        execute_process(COMMAND cmake -E create_symlink 
            ${file} ${INCLUDE_DIR}/${f})
    endforeach()
endforeach()
