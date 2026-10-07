function(osm_configure_audio_backend target)
    if(WIN32)
        message(STATUS "Open Sound Meter audio backend: WASAPI")
        # WASAPI includes Windows headers, including in the combined moc source.
        # Keep their min/max macros from colliding with chart methods.
        target_compile_definitions(${target} PRIVATE NOMINMAX)
        target_sources(${target} PRIVATE
            src/audio/plugins/wasapi.cpp
            src/audio/plugins/wasapi.h
        )
        target_link_libraries(${target} PRIVATE ole32)

        set(OSM_ASIO_SDK "" CACHE PATH "Path to an external ASIO SDK")
        if(OSM_ASIO_SDK)
            set(asio_required_files
                common/asio.cpp
                common/asio.h
                common/asiosys.h
                host/asiodrivers.cpp
                host/asiodrivers.h
                host/pc/asiolist.cpp
                host/pc/asiolist.h
            )
            foreach(asio_file IN LISTS asio_required_files)
                if(NOT EXISTS "${OSM_ASIO_SDK}/${asio_file}")
                    message(FATAL_ERROR
                        "OSM_ASIO_SDK is missing required file: ${asio_file}"
                    )
                endif()
            endforeach()

            message(STATUS "Open Sound Meter optional audio backend: ASIO")
            target_compile_definitions(${target} PRIVATE USE_ASIO)
            target_include_directories(${target} PRIVATE
                "${OSM_ASIO_SDK}/common"
                "${OSM_ASIO_SDK}/host"
                "${OSM_ASIO_SDK}/host/pc"
            )
            target_sources(${target} PRIVATE
                src/audio/plugins/asioplugin.cpp
                src/audio/plugins/asioplugin.h
                "${OSM_ASIO_SDK}/common/asio.cpp"
                "${OSM_ASIO_SDK}/host/asiodrivers.cpp"
                "${OSM_ASIO_SDK}/host/pc/asiolist.cpp"
            )
            target_link_libraries(${target} PRIVATE Advapi32)
        endif()
    elseif(APPLE)
        message(STATUS "Open Sound Meter audio backend: CoreAudio")
        find_library(OSM_COREAUDIO_FRAMEWORK CoreAudio REQUIRED)
        find_library(OSM_AUDIOTOOLBOX_FRAMEWORK AudioToolbox REQUIRED)
        target_sources(${target} PRIVATE
            src/audio/plugins/coreaudio.cpp
            src/audio/plugins/coreaudio.h
        )
        target_link_libraries(${target} PRIVATE
            "${OSM_COREAUDIO_FRAMEWORK}"
            "${OSM_AUDIOTOOLBOX_FRAMEWORK}"
        )
    elseif(UNIX)
        message(STATUS "Open Sound Meter audio backend: ALSA")
        find_package(ALSA REQUIRED)
        target_sources(${target} PRIVATE
            src/audio/plugins/alsa.cpp
            src/audio/plugins/alsa.h
        )
        target_link_libraries(${target} PRIVATE ALSA::ALSA)
    else()
        message(FATAL_ERROR
            "Unsupported desktop platform: no native audio backend is available"
        )
    endif()
endfunction()
