set(OSM_GRAPH_BACKEND "OPENGL" CACHE STRING "Chart renderer: OPENGL or METAL")
set_property(CACHE OSM_GRAPH_BACKEND PROPERTY STRINGS OPENGL METAL)

function(osm_configure_render_backend target)
    string(TOUPPER "${OSM_GRAPH_BACKEND}" graph_backend)

    if(graph_backend STREQUAL "OPENGL")
        message(STATUS "Open Sound Meter chart backend: OpenGL")
        target_compile_definitions(${target} PRIVATE GRAPH_OPENGL)
        target_include_directories(${target} PRIVATE src/chart/opengl)
        target_sources(${target} PRIVATE
            src/chart/opengl/coherenceseriesrenderer.cpp
            src/chart/opengl/coherenceseriesrenderer.h
            src/chart/opengl/crestfactorseriesrenderer.cpp
            src/chart/opengl/crestfactorseriesrenderer.h
            src/chart/opengl/frequencybasedseriesrenderer.cpp
            src/chart/opengl/frequencybasedseriesrenderer.h
            src/chart/opengl/groupdelayseriesrenderer.cpp
            src/chart/opengl/groupdelayseriesrenderer.h
            src/chart/opengl/impulseseriesrenderer.cpp
            src/chart/opengl/impulseseriesrenderer.h
            src/chart/opengl/levelseriesrenderer.cpp
            src/chart/opengl/levelseriesrenderer.h
            src/chart/opengl/magnitudeseriesrenderer.cpp
            src/chart/opengl/magnitudeseriesrenderer.h
            src/chart/opengl/nyquistseriesrenderer.cpp
            src/chart/opengl/nyquistseriesrenderer.h
            src/chart/opengl/phasedelayseriesrenderer.cpp
            src/chart/opengl/phasedelayseriesrenderer.h
            src/chart/opengl/phaseseriesrenderer.cpp
            src/chart/opengl/phaseseriesrenderer.h
            src/chart/opengl/plotseriescreator.cpp
            src/chart/opengl/rtaseriesrenderer.cpp
            src/chart/opengl/rtaseriesrenderer.h
            src/chart/opengl/seriesfbo.cpp
            src/chart/opengl/seriesfbo.h
            src/chart/opengl/seriesrenderer.cpp
            src/chart/opengl/seriesrenderer.h
            src/chart/opengl/spectrogramseriesrenderer.cpp
            src/chart/opengl/spectrogramseriesrenderer.h
            src/chart/opengl/stepseriesrenderer.cpp
            src/chart/opengl/stepseriesrenderer.h
            src/chart/opengl/xyseriesrenderer.cpp
            src/chart/opengl/xyseriesrenderer.h
        )
    elseif(graph_backend STREQUAL "METAL")
        if(NOT APPLE)
            message(FATAL_ERROR "OSM_GRAPH_BACKEND=METAL is supported only on macOS")
        endif()

        enable_language(OBJCXX)
        message(STATUS "Open Sound Meter chart backend: Metal")
        find_library(OSM_METAL_FRAMEWORK Metal REQUIRED)
        find_program(OSM_XCRUN_EXECUTABLE xcrun REQUIRED)

        target_compile_definitions(${target} PRIVATE GRAPH_METAL)
        target_include_directories(${target} PRIVATE src/chart/metal)
        target_sources(${target} PRIVATE
            src/chart/metal/coherenceseriesnode.h
            src/chart/metal/coherenceseriesnode.mm
            src/chart/metal/crestfactorseriesnode.h
            src/chart/metal/crestfactorseriesnode.mm
            src/chart/metal/groupdelayseriesnode.h
            src/chart/metal/groupdelayseriesnode.mm
            src/chart/metal/impulseseriesnode.h
            src/chart/metal/impulseseriesnode.mm
            src/chart/metal/levelseriesnode.h
            src/chart/metal/levelseriesnode.mm
            src/chart/metal/magnitudeseriesnode.h
            src/chart/metal/magnitudeseriesnode.mm
            src/chart/metal/nyquistseriesnode.h
            src/chart/metal/nyquistseriesnode.mm
            src/chart/metal/phasedelayseriesnode.h
            src/chart/metal/phasedelayseriesnode.mm
            src/chart/metal/phaseseriesnode.h
            src/chart/metal/phaseseriesnode.mm
            src/chart/metal/plotseriescreator.cpp
            src/chart/metal/rtaseriesnode.h
            src/chart/metal/rtaseriesnode.mm
            src/chart/metal/seriesitem.cpp
            src/chart/metal/seriesitem.h
            src/chart/metal/seriesnode.h
            src/chart/metal/seriesnode.mm
            src/chart/metal/spectrogramseriesnode.h
            src/chart/metal/spectrogramseriesnode.mm
            src/chart/metal/stepseriesnode.h
            src/chart/metal/stepseriesnode.mm
            src/chart/metal/xyseriesnode.h
            src/chart/metal/xyseriesnode.mm
        )
        target_link_libraries(${target} PRIVATE "${OSM_METAL_FRAMEWORK}")

        set(metal_source "${CMAKE_CURRENT_SOURCE_DIR}/src/chart/metal/shaders.metal")
        set(metal_air "${CMAKE_CURRENT_BINARY_DIR}/OpenSoundMeter-shaders.air")
        set(metal_library "${CMAKE_CURRENT_BINARY_DIR}/lib.metallib")
        add_custom_command(
            OUTPUT "${metal_library}"
            COMMAND "${OSM_XCRUN_EXECUTABLE}" -sdk macosx metal
                -mmacosx-version-min=12.0
                -std=macos-metal1.0
                -c "${metal_source}"
                -o "${metal_air}"
            COMMAND "${OSM_XCRUN_EXECUTABLE}" -sdk macosx metallib
                "${metal_air}"
                -o "${metal_library}"
            DEPENDS "${metal_source}"
            COMMENT "Compiling Open Sound Meter Metal shaders"
            VERBATIM
        )
        add_custom_target(OpenSoundMeterMetalLibrary DEPENDS "${metal_library}")
        add_dependencies(${target} OpenSoundMeterMetalLibrary)
        set_property(TARGET ${target} PROPERTY OSM_METAL_LIBRARY "${metal_library}")
    else()
        message(FATAL_ERROR
            "Invalid OSM_GRAPH_BACKEND='${OSM_GRAPH_BACKEND}'; use OPENGL or METAL"
        )
    endif()
endfunction()
