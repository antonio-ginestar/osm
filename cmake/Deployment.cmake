if(WIN32)
    enable_language(RC)
endif()

function(osm_configure_deployment target)
    if(APPLE)
        set_source_files_properties("${PROJECT_SOURCE_DIR}/icons/white.icns"
            PROPERTIES MACOSX_PACKAGE_LOCATION Resources
        )
        target_sources(${target} PRIVATE "${PROJECT_SOURCE_DIR}/icons/white.icns")
        get_target_property(metal_library ${target} OSM_METAL_LIBRARY)
        if(metal_library)
            set_source_files_properties("${metal_library}"
                PROPERTIES MACOSX_PACKAGE_LOCATION Resources
            )
            target_sources(${target} PRIVATE "${metal_library}")
        endif()
        set_target_properties(${target} PROPERTIES
            MACOSX_BUNDLE TRUE
            MACOSX_BUNDLE_ICON_FILE white.icns
            MACOSX_BUNDLE_INFO_PLIST "${PROJECT_SOURCE_DIR}/Info.plist"
            XCODE_ATTRIBUTE_CODE_SIGN_ENTITLEMENTS "${PROJECT_SOURCE_DIR}/info.entitlements"
        )
    elseif(WIN32)
        configure_file(
            "${PROJECT_SOURCE_DIR}/cmake/OpenSoundMeter.rc.in"
            "${CMAKE_CURRENT_BINARY_DIR}/OpenSoundMeter.rc"
            @ONLY
        )
        target_sources(${target} PRIVATE
            "${CMAKE_CURRENT_BINARY_DIR}/OpenSoundMeter.rc"
        )
        set_target_properties(${target} PROPERTIES WIN32_EXECUTABLE TRUE)
    elseif(UNIX)
        install(FILES "${PROJECT_SOURCE_DIR}/OpenSoundMeter.desktop"
            DESTINATION "${CMAKE_INSTALL_DATADIR}/applications"
        )
        install(FILES "${PROJECT_SOURCE_DIR}/icons/white.png"
            DESTINATION "${CMAKE_INSTALL_DATADIR}/icons/hicolor/1024x1024/apps"
            RENAME opensoundmeter.png
        )
    endif()

    install(TARGETS ${target}
        BUNDLE DESTINATION .
        RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
    )

    qt_generate_deploy_qml_app_script(
        TARGET ${target}
        OUTPUT_SCRIPT deploy_script
        NO_UNSUPPORTED_PLATFORM_ERROR
    )
    install(SCRIPT "${deploy_script}")
endfunction()
