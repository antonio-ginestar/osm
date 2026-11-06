# Desktop CI

`.github/workflows/desktop.yml` runs on pushes, pull requests, and manual
dispatches. Each matrix job must build Release, pass QML lint and all six
device-independent CTests, and stage the application with Qt's deployment
script. A failure in one job does not cancel the other platform checks.

| Job | Hosted runner | Audio compiled | Chart renderer compiled |
| --- | --- | --- | --- |
| windows-opengl | windows-2022, MSVC 2022 x64 | WASAPI | OpenGL |
| linux-opengl | ubuntu-24.04, GCC x64 | ALSA | OpenGL |
| macos-opengl | macos-15-intel, Xcode 16.4 | CoreAudio | OpenGL |
| macos-metal | macos-15-intel, Xcode 16.4 | CoreAudio | Metal, including shaders |

All jobs use Qt 6.12.0. The layout tests select offscreen/software rendering
because they test layout, persistence, scrolling, and pointer handling without
a GPU. The chart layout test uses an inert chart delegate. This does not verify
native OpenGL/Metal rendering or real audio devices. The separate WASAPI
hardware test is deliberately not registered with CTest.
The value-conversion and network/settings tests use a core application without
initializing the window system.

## Artifacts and failures

Successful jobs upload `OpenSoundMeter-<job>.tar` containing the installed
application, deployed Qt dependencies, and license. Download the artifact ZIP
from the run, then extract the contained tar archive; the tar preserves macOS
framework symlinks and executable permissions. These are unsigned test builds,
not releases or installers. Keep the entire extracted directory together.
On Windows, run the included `bin/vc_redist.x64.exe` if the machine lacks the
Microsoft Visual C++ runtime, then start `bin/OpenSoundMeter.exe`. Windows
staging fails if this runtime installer is missing.

Diagnostic artifacts contain CTest's `LastTest.log` and CMake's configure log
when available, including on failed jobs. Application and log artifacts expire
after seven days. Full compiler and lint output remains in the job steps.

## Reproduce locally

Use the matching Qt 6.12 development environment. Linux additionally needs ALSA
and OpenGL development packages; macOS needs Xcode and the Metal tools.

```sh
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH=/absolute/path/to/Qt/6.12.0/kit \
  -DBUILD_TESTING=ON -DOSM_GRAPH_BACKEND=OPENGL
cmake --build build --config Release --parallel 2
cmake --build build --config Release --target all_qmllint
ctest --test-dir build -C Release --output-on-failure --no-tests=error
cmake --install build --config Release --prefix /absolute/path/to/stage
```

On Windows replace the generator with `-G "Visual Studio 17 2022" -A x64`;
the `--config Release` and `-C Release` arguments select the configuration.
For the second macOS check use `-DOSM_GRAPH_BACKEND=METAL` in a separate build
directory. See [CONTRIBUTING](../CONTRIBUTING.md) for desktop and hardware checks.

## Tooling and trust boundaries

Actions are pinned to immutable commits. The workflow token is read-only and
checkout does not persist credentials. Pull-request code runs without secrets;
there is no deployment or privileged `pull_request_target` workflow. Qt caching
is handled by the pinned install action. Changes to Qt/tool versions should
update the pins and rerun all four jobs.

The pinned upstream aqtinstall revision supports Qt's new Windows compiler
subdirectories; aqtinstall 3.3.0 does not. The Python version is 3.12 and py7zr
is pinned to 1.1.3. The Qt base archives and addon modules match the locally
validated Windows kit, including `qttasktree` needed by Qt 6.12 QML tooling.
Linux also installs Qt's `icu` archive: the official Qt binaries require ICU
73, which the clean hosted runner does not provide.

Sources:

- [Qt 6.12 supported platforms](https://doc.qt.io/qt-6.12/supported-platforms.html)
- [Install Qt action inputs](https://github.com/jurplel/install-qt-action/blob/v4.5.0/README.md)
- [Pinned aqtinstall revision](https://github.com/miurahr/aqtinstall/commit/5a49f2b391ae8ee1d3c0dd87f8b33c1d49a4deb7)
- [macOS runner toolchains](https://github.com/actions/runner-images/blob/main/images/macos/macos-15-Readme.md)
- [GitHub artifact storage](https://docs.github.com/en/actions/tutorials/store-and-share-data)

## Remaining acceptance work

Passing CI proves compilation, the automated tests, lint, and staging on its
listed runners. Desktop audio, actual chart rendering, interactive remote
control, clean-machine startup, ASIO, signing/notarization, and release approval
remain separate. Interactive remote-control verification was deferred by the
user. CI does not retire the qmake build or change branch-protection settings.
