# Qt 6.12.0 upgrade

The CMake build requires Qt 6.12.0 or newer and CMake 3.25 or newer. It enables
Qt CMake policies through 6.12, including the updated deployment argument
handling. The application remains C++17 and uses the existing native audio,
OpenGL, and optional Metal backends.

Install a Qt 6.12.0 desktop kit matching your compiler with the modules listed
in [CONTRIBUTING.md](../CONTRIBUTING.md). Qt's bundled QML asset downloader also
depends on TaskTree: include that module when installing the prebuilt kit to
avoid a missing `Qt6TaskTree` dependency warning during configuration.

Qt 6.12's supported desktop prerequisites include:

- macOS 14.4 or newer with Xcode 16 or newer. The application's default CMake
  deployment target and bundle metadata use 14.4; Metal shader compilation uses
  the CMake deployment target.
- Windows 10 version 1809 or newer, or Windows 11, with MSVC 2022 or
  MinGW-w64 15.1. Use the matching Qt kit and compiler environment.
- Linux with the kit's system runtime dependencies, plus ALSA and OpenGL
  development files. Official x86-64 binaries require glibc 2.34 or newer;
  official Arm desktop binaries require glibc 2.39 or newer.

Configure a fresh build directory when switching kits. CMake caches paths to
individual Qt modules, so changing only `CMAKE_PREFIX_PATH` in an old build
directory can retain references to Qt 6.8. For example, on Linux:

```sh
/path/to/Qt/6.12.0/gcc_64/bin/qt-cmake -S . -B build-qt612 \
    -DCMAKE_BUILD_TYPE=Release -DOSM_GRAPH_BACKEND=OPENGL
cmake --build build-qt612 --parallel
ctest --test-dir build-qt612 --output-on-failure
cmake --build build-qt612 --target all_qmllint
cmake --install build-qt612 --prefix "$PWD/build-qt612/stage"
./build-qt612/stage/bin/OpenSoundMeter
```

Remote TCP response transmission uses the public `QByteArray::constData()` API.
The previous access through `data_ptr()->data()` depended on Qt internals and
does not compile with 6.12. The network regression test checks empty, binary,
and multiple-chunk compressed responses without changing the wire format.

## Validation

Linux validation on 2026-10-07 used the official Qt 6.12.0 x86-64 kit,
GCC 14.2.0, CMake 3.31.6, and a fresh Release/Ninja build directory:

- Configuration and the full application build passed. Configuring against
  the previous Qt 6.8.2 kit was rejected as expected.
- All four CTest tests passed: QML resource manifest, remote JSON conversion,
  settings persistence, and remote TCP responses. The new network test failed
  to compile with the original Qt internal data access and passed with the fix.
- `all_qmllint` completed with exit status zero, reporting 1499 warnings,
  including unqualified access and unresolved manually registered C++ types.
  Lint output is not warning-free.
- Installation deployed Qt libraries, plugins, QML modules, runtime configuration,
  desktop metadata, and the application icon. Qt's deployment script reported
  four missing-translation locale warnings.
- The staged executable launched from `/tmp` with isolated settings and stayed
  running for 12 seconds. The Qt Quick scene graph created an OpenGL 4.5 context
  through Mesa llvmpipe. Two `About.qml` recursive layout warnings remain;
  recursive layout warnings were also reproduced with the cached Qt 6.8 build.

The host required the existing local ALSA development headers and locally
extracted XCB runtime packages. XCB libraries remain system dependencies of the
staged application. The host has no audio device, so the startup check does not
verify audio capture/playback or hardware rendering performance.

macOS CoreAudio/OpenGL/Metal builds and Windows ASIO validation remain pending.
Interactive audio, chart, file-dialog, project, and remote-control workflows
still need hands-on verification before a release.

The original [Qt 6.8 port specification](qt6-port-spec.md) and migration
checklists retain historical build versions and results.

### Windows validation

Windows validation on 2026-10-07 used the official Qt 6.12.0
`msvc2022_64` kit, MSVC 19.44.35215, Windows SDK 10.0.26100.0, and
CMake 3.31.6-msvc6. The kit was installed locally under
`build-windows-tools/Qt/6.12.0`, including TaskTree and ShaderTools.
The local build, audio, and layout helpers were updated to use this kit.
The previous Qt 6.8.3 kit and running application were retained.

The fresh Visual Studio x64 build directory is `build-windows-qt612`, configured
with `OSM_GRAPH_BACKEND=OPENGL`, the new kit as `CMAKE_PREFIX_PATH`, and `/MP4`:

```powershell
python build-windows-tools/run-tool.py cmake --build build-windows-qt612 --config Debug --parallel 4
python build-windows-tools/run-tool.py ctest --test-dir build-windows-qt612 -C Debug --output-on-failure
python build-windows-tools/run-tool.py cmake --build build-windows-qt612 --config Debug --target all_qmllint --parallel 4
python build-windows-tools/run-tool.py cmake --install build-windows-qt612 --config Debug `
    --prefix C:/Users/Dev/Documents/MyWork/osm/build-windows-qt612/stage
```

- The application build and all four CTest tests passed. Test logs identify
  QtTest and Qt as version 6.12.0.
- `all_qmllint` passed with existing static-analysis warnings.
- Deployment succeeded; the deployed Qt Core DLL reports version 6.12.0.0.
  The executable is `build-windows-qt612/stage/bin/OpenSoundMeter.exe`.
- A local probe compiling the repository's WASAPI backend enumerated three
  active devices and passed two capture and two silent playback cycles.
  Captured samples were counted without being saved. The existing
  `QIODevice` access-after-close warnings remain.
- The local layout probe linked against the new application objects, used
  isolated settings, and ran with the deployed DLLs/plugins and only Windows
  system directories on PATH. It exited successfully, rendered at 3439x1366,
  1024x768, and 768x540, and initialized hardware OpenGL 4.6 on the RTX 5070.
  The two existing `About.qml` recursive layout warnings remain.

Logs and local probe sources are retained in the ignored build/tools directories.
This checks Debug on the development machine; Release redistribution and ASIO
remain unverified. No application source changes were needed for this Windows
Qt kit update.

## Sources

- [Qt 6.12 release announcement](https://www.qt.io/blog/qt-6.12-released)
- [Supported platforms](https://doc.qt.io/qt-6.12/supported-platforms.html)
- [Supported CMake versions](https://doc.qt.io/qt-6.12/cmake-supported-cmake-versions.html)
- [Qt CMake project setup and policies](https://doc.qt.io/qt-6.12/qt-standard-project-setup.html)
- [QByteArray public data access](https://doc.qt.io/qt-6.12/qbytearray.html#constData)
