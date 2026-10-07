# Open Sound Meter

Cross-platform, real-time sound measurement software for tuning audio systems.

**Supported systems:** macOS, Windows, Linux

This checkout uses Qt 6.8 and CMake. The application version is derived from
`git describe --tags --always` when configuring the build.

[Project page](https://opensoundmeter.com/) ·
[Downloads](https://opensoundmeter.com/download) ·
[User support](https://opensoundmeter.com/support)

![Open Sound Meter measurement workspace](docs/images/screens/main.png)

## Features

- Real-time spectrum analysis, magnitude, phase, impulse response, coherence,
  group delay, phase delay, spectrogram, step response, and Nyquist plots.
- SPL and level meters, signal generation, and a wavelength calculator.
- Stored measurements, source groups, and virtual summation and averaging.
- Project save/load, measurement import, and export to formats including CSV,
  FRD, and WAV.
- Remote measurement access and generator control.

## Building

Open Sound Meter uses Qt 6.8 LTS, a C++17 compiler, and CMake 3.21 or newer.
Install a desktop Qt kit with Core, Gui, Network, OpenGL, QML, Quick, Quick
Controls, Quick Dialogs, Test, and Widgets. Use CMake as the build entry point;
the legacy qmake files remain while migration validation is completed.

| Platform | Native audio backend | Chart renderer |
| --- | --- | --- |
| Linux | ALSA | OpenGL |
| macOS | CoreAudio | OpenGL, or optional Metal |
| Windows | WASAPI, plus optional ASIO with an external SDK | OpenGL |

### Linux

Install Qt 6.8, OpenGL development files, and the ALSA development package
(`libasound2-dev` on Debian-derived distributions). Replace the Qt path below
with your installed kit:

```sh
/path/to/Qt/6.8.x/gcc_64/bin/qt-cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DOSM_GRAPH_BACKEND=OPENGL
cmake --build build --parallel
ctest --test-dir build --output-on-failure
cmake --install build --prefix stage
./stage/bin/OpenSoundMeter
```

### Windows

Use a Qt kit matching your compiler and run these commands from its developer
shell. This example uses MSVC 2022 and a multi-configuration generator:

```powershell
C:\Qt\6.8.x\msvc2022_64\bin\qt-cmake.bat -S . -B build `
    -DOSM_GRAPH_BACKEND=OPENGL
cmake --build build --config Release --parallel
ctest --test-dir build -C Release --output-on-failure
cmake --install build --config Release --prefix "$PWD/stage"
.\stage\bin\OpenSoundMeter.exe
```

The install step deploys the Qt DLLs, plugins, and QML modules. Run the staged
executable; the executable in `build/Release` needs the Qt development environment
to run. Use an absolute install prefix as shown above because Qt 6.8's deployment
script requires it. Keep the entire staging folder when copying the application.

See [CONTRIBUTING.md](CONTRIBUTING.md) for platform-specific prerequisites,
macOS Metal and Windows ASIO options, debug builds, testing, and installation.

## Development checks

CTest covers the QML resource manifest, remote JSON value conversion, and
settings persistence. Tests are enabled by default through `BUILD_TESTING`.
Run QML static checks with:

```sh
cmake --build build --target all_qmllint --parallel
```

For multi-configuration generators, add `--config Debug` or `--config Release`
to the build command and the matching `-C` option to CTest.

The [Qt 6 port specification](docs/qt6-port-spec.md) and
[migration checklist](tasks/todo.md) track the migration and remaining platform
validation. See the [Qt 6 layout validation notes](docs/qt6-layout-validation.md)
for the Windows sidebar and stored-measurement layout checks and their limits.

## License

Open Sound Meter is distributed under the GNU General Public License, version 3
or later. See [LICENSE](LICENSE) for the full text.

## SAST Tools

[PVS-Studio](https://pvs-studio.com/pvs-studio/?utm_source=website&utm_medium=github&utm_campaign=open_source) - static analyzer for C, C++, C#, and Java code.
