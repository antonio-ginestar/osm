# Spec: Qt 6.8 LTS Port

## Objective

Port Open Sound Meter from Qt 5.15/qmake to a Qt 6.8 LTS-only CMake build for Linux, macOS, and Windows. Preserve existing desktop workflows, project/session compatibility, remote-control behavior, audio-device behavior, and chart behavior. Keep visual changes minimal, while allowing controls and native dialogs to follow Qt 6 platform rendering where exact Qt 5 rendering is unavailable.

## Acceptance Criteria

- The project configures and builds with Qt 6.8 using CMake on Linux, macOS, and Windows.
- The qmake project is no longer the supported build entry point.
- No QML file imports Qt Quick Controls 1, Qt Quick Dialogs 1, or another module removed from Qt 6.
- Existing project create/open/save/import and recent-file workflows remain functional.
- Source creation, chart layout, generator, measurement, settings, remote-control, and shutdown/autosave workflows remain functional.
- ALSA is used on Linux, CoreAudio on macOS, WASAPI on Windows, and ASIO remains optional when an external SDK is supplied.
- Existing `.osm` files and remote protocol payloads remain compatible.
- The OpenGL chart backend works on all target platforms; the existing Metal backend remains an optional macOS build mode.
- QML linting and all automated tests pass, with no Qt deprecation warnings introduced by the port.
- Desktop packaging metadata and icons remain wired into the CMake targets.

## Tech Stack

- C++17
- Qt 6.8 LTS: Core, Gui, Widgets, Network, Qml, Quick, QuickControls2, QuickDialogs2, and OpenGL
- QML with versionless Qt 6 imports
- CMake 3.21 or newer
- Native audio APIs: ALSA, CoreAudio/AudioToolbox, WASAPI, and optional ASIO
- Custom OpenGL renderer on all desktops; optional custom Metal renderer on macOS

Qt's supported migration direction is used throughout:

- [Qt 6 module changes](https://doc.qt.io/qt-6.8/modulechanges.html)
- [Qt Quick Controls changes](https://doc.qt.io/qt-6.8/qtquickcontrols-changes-qt6.html)
- [Building a QML application with CMake](https://doc.qt.io/qt-6.8/cmake-build-qml-application.html)
- [`qt_add_qml_module`](https://doc.qt.io/qt-6.8/qt-add-qml-module.html)
- [Qt Quick Dialogs](https://doc.qt.io/qt-6.8/qtquickdialogs-index.html)
- [Qt 6 desktop deployment with CMake](https://doc.qt.io/qt-6.8/cmake-deployment.html)

## Commands

Assume `CMAKE_PREFIX_PATH` names a Qt 6.8 desktop kit when Qt is not discoverable automatically.

```sh
# Configure the default OpenGL build
cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug -DCMAKE_PREFIX_PATH=/path/to/Qt/6.8.x/<kit>

# Build
cmake --build build --parallel

# QML static checks
cmake --build build --target all_qmllint

# Automated tests
ctest --test-dir build --output-on-failure

# Run on a single-config Linux/macOS development build
./build/OpenSoundMeter

# Configure the optional macOS Metal backend
cmake -S . -B build-metal -DCMAKE_BUILD_TYPE=Debug -DOSM_GRAPH_BACKEND=METAL -DCMAKE_PREFIX_PATH=/path/to/Qt/6.8.x/macos
```

Windows and multi-config generators run the configuration-specific executable, for example `build/Debug/OpenSoundMeter.exe`.

## Project Structure

```text
CMakeLists.txt           Top-level Qt 6 application target and platform selection
cmake/                   Focused CMake helpers when platform logic is too large for the root file
src/                     C++ application, audio, chart, model, remote, and support code
src/audio/plugins/       ALSA, CoreAudio, WASAPI, and optional ASIO implementations
src/chart/opengl/        Default chart rendering backend
src/chart/metal/         Optional macOS Metal chart rendering backend
qml/                     QML application and controls
shaders/                 OpenGL shaders embedded as resources
audio/, fonts/, icons/   Runtime assets and platform icons
tests/                   New focused regression and startup tests
tasks/                   Migration plan and task checklist
docs/                    User and migration documentation
```

## Code Style

Preserve the existing C++17 style and namespace organization. Prefer explicit Qt 6 types and `nullptr`; avoid unrelated formatting churn.

```cpp
QString Client::deviceName(const DeviceInfo::Id &id) const
{
    const auto it = std::find_if(m_deviceList.cbegin(), m_deviceList.cend(), [&id](const auto &device) {
        return device.id() == id;
    });
    return it == m_deviceList.cend() ? QString{} : it->name();
}
```

QML uses versionless Qt imports and explicit signal handlers:

```qml
import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs

FileDialog {
    onAccepted: sourceList.load(selectedFile)
}
```

## Testing Strategy

- Establish the Qt 6 CMake configure/build as the first migration test.
- Enable CMake `AUTOMOC`, `AUTORCC`, `AUTOUIC`, Qt deprecation warnings, and CTest.
- Run the generated `all_qmllint` target for the full QML module.
- Add focused tests for compatibility-sensitive pure/model behavior where practical, especially project serialization and remote payload type conversion.
- Add a headless startup smoke check when the platform/renderer supports it; do not treat it as a substitute for real desktop runtime checks.
- Manually verify, on each target OS: startup, menus and shortcuts, source creation, chart resizing, project save/open/import, recent files, generator/audio device enumeration, remote controls, settings persistence, and clean shutdown/autosave.
- Verify both OpenGL and Metal on macOS if the Metal option is retained through implementation.

The current development environment has CMake 3.31 but no discoverable Qt installation, so compile and runtime checks remain pending until a Qt 6.8 kit or suitable CI runner is available.

## Migration Boundaries

### Always

- Preserve observable behavior and serialized/network formats.
- Use documented Qt 6.8 APIs and CMake targets.
- Migrate in buildable, reviewable slices and run the available checks after each slice.
- Keep platform-specific code isolated behind CMake platform conditions.
- Update the spec and task list if a discovered Qt 6 incompatibility changes the approach.

### Ask First

- Drop or replace an existing user workflow.
- Change `.osm` serialization or the remote protocol.
- Remove the optional Metal or ASIO backend.
- Add a non-Qt runtime dependency.
- Redesign the UI beyond the minimum needed for Qt 6 controls.
- Change supported compiler, architecture, or OS baselines beyond Qt 6.8 requirements.

### Never

- Add Qt 5 compatibility build paths.
- Reintroduce Qt Quick Controls 1 or Qt Quick Dialogs 1.
- Rewrite the audio subsystem onto Qt Multimedia as part of this port.
- Modify unrelated DSP algorithms or measurement behavior.
- Commit proprietary ASIO SDK files, generated build output, credentials, or signing material.
- Delete the qmake project until CMake has reached feature parity and the Qt 6 build has been verified.

## Success Criteria

The port is complete when clean Qt 6.8 CMake builds pass on Linux, macOS, and Windows; QML linting and automated tests pass; all listed workflows have been exercised on the three desktop platforms; the OpenGL renderer is functional; optional Metal and ASIO behavior is either verified or explicitly documented with the user's approval; packaging metadata is present; and the qmake build is retired only after parity is demonstrated.

## Open Questions

- Where will Qt 6.8 builds be executed for the three operating systems (local kits, existing CI, or new CI)?
- Are proprietary ASIO SDK and signing/notarization assets available to their respective platform verification environments?
