add_test(
    NAME qml_resource_manifest
    COMMAND "${CMAKE_COMMAND}"
        -DQML_RESOURCE_MANIFEST=${CMAKE_BINARY_DIR}/.qt/rcc/OpenSoundMeter_raw_qml_0.qrc
        -P "${CMAKE_CURRENT_SOURCE_DIR}/verify_qml_resources.cmake"
)
