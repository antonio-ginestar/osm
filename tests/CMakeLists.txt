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

qt_add_executable(remote_network_test
    remote_network_test.cpp
    "${PROJECT_SOURCE_DIR}/src/remote/network.cpp"
    "${PROJECT_SOURCE_DIR}/src/remote/network.h"
    "${PROJECT_SOURCE_DIR}/src/remote/tcpreciever.cpp"
    "${PROJECT_SOURCE_DIR}/src/remote/tcpreciever.h"
)
target_include_directories(remote_network_test PRIVATE "${PROJECT_SOURCE_DIR}/src")
target_link_libraries(remote_network_test PRIVATE Qt6::Network Qt6::Test)
add_test(NAME remote_network_test COMMAND remote_network_test)
set_tests_properties(remote_network_test PROPERTIES TIMEOUT 20)

qt_add_executable(charts_layout_test
    charts_layout_test.cpp
    "${PROJECT_SOURCE_DIR}/src/common/settings.cpp"
    "${PROJECT_SOURCE_DIR}/src/common/settings.h"
    "${PROJECT_SOURCE_DIR}/src/common/workingfolder.cpp"
    "${PROJECT_SOURCE_DIR}/src/common/workingfolder.h"
)
target_include_directories(charts_layout_test PRIVATE "${PROJECT_SOURCE_DIR}/src")
target_compile_definitions(charts_layout_test PRIVATE
    OSM_CHARTS_QML_FILE="${PROJECT_SOURCE_DIR}/qml/Charts.qml"
)
target_link_libraries(charts_layout_test PRIVATE Qt6::Quick Qt6::QuickControls2 Qt6::Test)
add_test(NAME charts_layout_test COMMAND charts_layout_test)
set_tests_properties(charts_layout_test PROPERTIES
    ENVIRONMENT "QT_QPA_PLATFORM=offscreen;QT_QUICK_CONTROLS_STYLE=Basic"
    TIMEOUT 30
)
