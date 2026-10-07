cmake_minimum_required(VERSION 3.25)

if(CMAKE_HOST_APPLE)
    set(CMAKE_OSX_DEPLOYMENT_TARGET "14.4" CACHE STRING "Minimum macOS version")
endif()

project(OpenSoundMeter LANGUAGES CXX)

include(CTest)
include(GNUInstallDirs)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_AUTORCC ON)

find_package(Qt6 6.12.0 REQUIRED COMPONENTS
    Core
    Gui
    Network
    OpenGL
    Qml
    Quick
    QuickControls2
    QuickDialogs2
    Test
    Widgets
)

qt_standard_project_setup(REQUIRES 6.12)

include(cmake/ApplicationSources.cmake)

if(CMAKE_SYSTEM_PROCESSOR MATCHES "^(aarch64|arm64|arm)")
    list(APPEND OSM_APPLICATION_SOURCES src/armmath.h)
else()
    list(APPEND OSM_APPLICATION_SOURCES
        src/math/ssemath.cpp
        src/math/ssemath.h
    )
endif()

qt_add_executable(OpenSoundMeter
    ${OSM_APPLICATION_SOURCES}
)

target_sources(OpenSoundMeter PRIVATE
    audio/noises.qrc
    fonts/fonts.qrc
    images.qrc
    shaders/shaders.qrc
)

include(qml/CMakeLists.txt)
include(cmake/AudioBackends.cmake)
osm_configure_audio_backend(OpenSoundMeter)
include(cmake/RenderBackends.cmake)
osm_configure_render_backend(OpenSoundMeter)

execute_process(
    COMMAND git describe --tags --always
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    OUTPUT_VARIABLE OSM_GIT_VERSION
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
)
if(NOT OSM_GIT_VERSION)
    set(OSM_GIT_VERSION "unknown")
endif()

target_compile_definitions(OpenSoundMeter PRIVATE
    APP_GIT_VERSION="${OSM_GIT_VERSION}"
    QT_DEPRECATED_WARNINGS
    QT_MESSAGELOGCONTEXT
)

target_include_directories(OpenSoundMeter PRIVATE
    src
    src/chart
    src/common
    src/generator
    src/meta
    src/model
    src/remote
    src/source
)

target_link_libraries(OpenSoundMeter PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Network
    Qt6::OpenGL
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::QuickDialogs2
    Qt6::Widgets
)

if(BUILD_TESTING)
    add_subdirectory(tests)
endif()

include(cmake/Deployment.cmake)
osm_configure_deployment(OpenSoundMeter)
