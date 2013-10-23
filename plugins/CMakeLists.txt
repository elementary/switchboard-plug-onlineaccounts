option(BUILD_PLUGINS "Whether to build plugins or not." ON)

if (BUILD_PLUGINS)
    message("-- Plugins enabled")

    set(DEPS_PACKAGES ${DEPS_PACKAGES} ${SRC_TARGET})
    include_directories(${CMAKE_BINARY_DIR}/src)
    
    add_subdirectory(Generic-OAuth)
else ()
    message("-- Plugins disabled")
endif ()
