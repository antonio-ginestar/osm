add_test(
    NAME qml_resource_manifest
    COMMAND "${CMAKE_COMMAND}"
        -DQML_RESOURCE_MANIFEST=${CMAKE_BINARY_DIR}/.qt/rcc/OpenSoundMeter_raw_qml_0.qrc
        -DQML_MODULE_DIRECTORY=${CMAKE_BINARY_DIR}/OpenSoundMeterModule
        -DQML_SOURCE_DIRECTORY=${PROJECT_SOURCE_DIR}/qml
        -P "${CMAKE_CURRENT_SOURCE_DIR}/verify_qml_resources.cmake"
)

qt_add_executable(remote_variant_test
    remote_variant_test.cpp
    "${PROJECT_SOURCE_DIR}/src/remote/variantjson.cpp"
    "${PROJECT_SOURCE_DIR}/src/remote/variantjson.h"
)
target_include_directories(remote_variant_test PRIVATE "${PROJECT_SOURCE_DIR}/src")
target_link_libraries(remote_variant_test PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Test
)
add_test(NAME remote_variant_test COMMAND remote_variant_test)

qt_add_executable(settings_test
    settings_test.cpp
    "${PROJECT_SOURCE_DIR}/src/common/settings.cpp"
    "${PROJECT_SOURCE_DIR}/src/common/settings.h"
    "${PROJECT_SOURCE_DIR}/src/common/workingfolder.cpp"
    "${PROJECT_SOURCE_DIR}/src/common/workingfolder.h"
)
target_include_directories(settings_test PRIVATE "${PROJECT_SOURCE_DIR}/src")
target_link_libraries(settings_test PRIVATE
    Qt6::Core
    Qt6::Test
)
add_test(NAME settings_test COMMAND settings_test)
