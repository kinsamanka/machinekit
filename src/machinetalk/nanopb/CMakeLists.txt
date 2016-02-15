foreach(tool nanopb_generator.py protoc-gen-nanopb)
    add_custom_command(
        OUTPUT ${PROJECT_PYTHON_DIR}/${tool} 
        COMMAND ${CMAKE_COMMAND} -E copy 
            ${CMAKE_CURRENT_SOURCE_DIR}/generator/${tool}
            ${PROJECT_PYTHON_DIR}/${tool}
        DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/generator/${tool})
    add_custom_target(${tool} DEPENDS ${PROJECT_PYTHON_DIR}/${tool})
endforeach()

add_library(nanopb OBJECT pb_common.c pb_encode.c pb_decode.c)

set(PROTOC_GEN_NANOPB ${PROJECT_BINARY_DIR}/lib/python/protoc-gen-nanopb
    PARENT_SCOPE)
