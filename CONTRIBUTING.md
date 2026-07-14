# Contributing to Open Sound Meter

Open Sound Meter is a Qt 6.8 LTS desktop application built as C++17 with CMake
3.21 or newer. Install the Qt modules selected by the desktop Qt installer;
the project requires Core, Gui, Network, OpenGL, QML, Quick, Quick Controls,
Quick Dialogs, Test, and Widgets.

See Qt's [supported platform matrix](https://doc.qt.io/qt-6.8/supported-platforms.html)
for the maintained Qt 6.8 operating systems and toolchains. Installation uses
Qt's [CMake deployment API](https://doc.qt.io/qt-6.8/cmake-deployment.html).

Keep generated build trees outside source control. The examples below use a
separate `build` directory and install into a separate `stage` directory.

## Linux

Install a C++17 compiler, CMake, Ninja or Make, Qt 6.8, OpenGL development
files, and ALSA development files. On Debian-derived distributions, the native
audio dependency is provided by `libasound2-dev`.

```sh
/path/to/Qt/6.8.x/gcc_64/bin/qt-cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Debug \
    -DOSM_GRAPH_BACKEND=OPENGL
cmake --build build --parallel
ctest --test-dir build --output-on-failure
cmake --install build --prefix stage
```

The staged executable is `stage/bin/OpenSoundMeter`. A desktop entry and icon
are installed below `stage/share`. The Qt deployment script also installs the
required Qt libraries, plugins, and QML modules. Normal Linux system runtime
libraries, including ALSA, OpenGL, and XCB libraries, remain distribution
dependencies.

## macOS

Qt 6.8 supports macOS 12 or newer and requires Xcode 15 or newer. OpenGL is the
default chart backend:

```sh
/path/to/Qt/6.8.x/macos/bin/qt-cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Debug \
    -DOSM_GRAPH_BACKEND=OPENGL
cmake --build build --parallel
ctest --test-dir build --output-on-failure
cmake --install build --prefix stage
```

To build the optional Metal chart renderer, use a separate build tree:

```sh
/path/to/Qt/6.8.x/macos/bin/qt-cmake -S . -B build-metal \
    -DCMAKE_BUILD_TYPE=Debug \
    -DOSM_GRAPH_BACKEND=METAL
cmake --build build-metal --parallel
ctest --test-dir build-metal --output-on-failure
cmake --install build-metal --prefix stage-metal
```

The staged application is `stage/OpenSoundMeter.app` (or the corresponding
`stage-metal` path). Microphone permission metadata and the application icon
are part of the bundle configuration. Signing and notarization credentials are
release-environment inputs and are not stored in this repository.

## Windows

Qt 6.8 supports Windows 10 version 1809 or newer and Windows 11. Use a Qt 6.8
kit matching MSVC 2022 or MinGW-w64 13.1. From a matching developer shell:

```powershell
C:\Qt\6.8.x\msvc2022_64\bin\qt-cmake.bat -S . -B build `
    -DOSM_GRAPH_BACKEND=OPENGL
cmake --build build --config Debug --parallel
ctest --test-dir build -C Debug --output-on-failure
cmake --install build --config Debug --prefix stage
```

WASAPI is always enabled on Windows. To add the optional ASIO backend, obtain
the ASIO SDK separately and pass its root directory at configure time:

```powershell
C:\Qt\6.8.x\msvc2022_64\bin\qt-cmake.bat -S . -B build-asio `
    -DOSM_GRAPH_BACKEND=OPENGL `
    -DOSM_ASIO_SDK=C:\path\to\asiosdk
cmake --build build-asio --config Debug --parallel
ctest --test-dir build-asio -C Debug --output-on-failure
cmake --install build-asio --config Debug --prefix stage-asio
```

Do not commit the ASIO SDK. The staged executable and deployed runtime are
placed below `stage` or `stage-asio`, and the executable contains the Windows
application icon.

## Release builds and checks

Use `-DCMAKE_BUILD_TYPE=Release` with single-configuration generators. With
Visual Studio or another multi-configuration generator, pass `--config Release`
to the build, test, and install commands.

Before submitting a change:

```sh
cmake --build build --parallel
ctest --test-dir build --output-on-failure
```

For a multi-configuration build, add `-C Debug` or `-C Release` to `ctest`.
Run the affected workflows manually, especially audio-device, chart-rendering,
project save/load, settings, and remote-control behavior.
