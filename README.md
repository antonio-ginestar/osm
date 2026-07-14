# Open Sound Meter

Cross-platform measurement software for tuning sound systems.

**Supported systems:** macOS, Windows, Linux

Current version: v1.4.1

[Project page](https://opensoundmeter.com/)

![](https://private-user-images.githubusercontent.com/683461/391698445-324038eb-a325-4951-9c29-ee404bebbf19.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MzkxMzYyMTcsIm5iZiI6MTczOTEzNTkxNywicGF0aCI6Ii82ODM0NjEvMzkxNjk4NDQ1LTMyNDAzOGViLWEzMjUtNDk1MS05YzI5LWVlNDA0YmViYmYxOS5wbmc_WC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBVkNPRFlMU0E1M1BRSzRaQSUyRjIwMjUwMjA5JTJGdXMtZWFzdC0xJTJGczMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI1MDIwOVQyMTE4MzdaJlgtQW16LUV4cGlyZXM9MzAwJlgtQW16LVNpZ25hdHVyZT1mODdmNmVmYmI0NTEyM2Y3YTg2MjZiMzc2MzE4NmM0M2MwOTdkYzc4ZTdlNDRlMWZkOGVjYTZkZWM1M2Y3NDczJlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCJ9.w1SSK4YF7kJ7cd3dIp8xrYIv-o0dCXNddjCdjO2vxYk)

## Building

Open Sound Meter uses Qt 6.8 LTS, C++17, and CMake 3.21 or newer. The supported
desktop audio backends are ALSA on Linux, CoreAudio on macOS, and WASAPI on
Windows. OpenGL is the default chart renderer; Metal is optional on macOS, and
ASIO is optional on Windows when an external SDK is supplied.

On Linux, with Qt 6.8 and the ALSA development package installed:

```sh
/path/to/Qt/6.8.x/gcc_64/bin/qt-cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DOSM_GRAPH_BACKEND=OPENGL
cmake --build build --parallel
ctest --test-dir build --output-on-failure
cmake --install build --prefix stage
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for platform-specific prerequisites,
macOS Metal and Windows ASIO options, debug builds, testing, and installation.


## SAST Tools

[PVS-Studio](https://pvs-studio.com/pvs-studio/?utm_source=website&utm_medium=github&utm_campaign=open_source) - static analyzer for C, C++, C#, and Java code.
