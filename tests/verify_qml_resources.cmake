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

set(qml_module_manifest "${QML_MODULE_DIRECTORY}/qmldir")
if(NOT EXISTS "${qml_module_manifest}")
    message(FATAL_ERROR "QML module manifest was not generated")
endif()

file(READ "${qml_module_manifest}" qml_module_types)
foreach(required_type IN ITEMS
    "LevelMeter 1.0 Meter.qml"
    "Meter 1.0 SPL/Meter.qml"
    "WindowingDelegate 1.0 source/Windowing.qml"
)
    string(FIND "${qml_module_types}" "${required_type}" type_position)
    if(type_position EQUAL -1)
        message(FATAL_ERROR
            "QML module manifest is missing type entry: ${required_type}"
        )
    endif()
endforeach()
