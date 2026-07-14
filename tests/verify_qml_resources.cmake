if(NOT EXISTS "${QML_RESOURCE_MANIFEST}")
    message(FATAL_ERROR "QML resource manifest was not generated")
endif()

file(READ "${QML_RESOURCE_MANIFEST}" qml_resource_manifest)
foreach(required_alias IN ITEMS
    main.qml
    Calculator.qml
    Plot/ImpulseProperties.qml
    source/Measurement.qml
)
    string(FIND
        "${qml_resource_manifest}"
        "alias=\"${required_alias}\""
        alias_position
    )
    if(alias_position EQUAL -1)
        message(FATAL_ERROR
            "QML resource manifest is missing alias: ${required_alias}"
        )
    endif()
endforeach()
