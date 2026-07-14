# Qt 6.8 Port Task Checklist

Each task follows the project-wide Definition of Done in addition to its task-specific checks. A task is not complete when verification is unavailable; mark its pending evidence explicitly.

## Task 1: Add the Qt 6.8 CMake application target

**Description:** Create the root CMake entry point and explicit common source inventory without changing application behavior.

**Acceptance criteria:**
- [x] CMake requires Qt 6.8, C++17, and the needed Qt modules.
- [x] All common C++ sources/headers from `OpenSoundMeter.pro` belong to the executable target.
- [x] Git-derived `APP_GIT_VERSION` has a deterministic fallback outside a Git checkout.

**Verification:**
- [x] `~/.local/Qt/6.8.2/gcc_64/bin/qt-cmake -S . -B build-qt6 -DCMAKE_BUILD_TYPE=Debug` generated successfully with GCC 14.2.0.
- [x] Compared the CMake source inventory against `OpenSoundMeter.pro`; only intentional ARM/SSE conditional entries differ.

**Dependencies:** None

**Files likely touched:** `CMakeLists.txt`, `cmake/ApplicationSources.cmake`

**Estimated scope:** Small

## Task 2: Add the QML module and preserve resource URLs

**Description:** Define the application QML module with `qt_add_qml_module()` and attach fonts, images, audio, and shaders without prematurely rewriting runtime URLs.

**Acceptance criteria:**
- [x] All QML files are declared to the CMake target.
- [x] Existing `qrc:/...` references resolve or receive a documented minimal source update.
- [x] QML lint targets are generated.

**Verification:**
- [x] Generated the QML resource manifest and the application autogen target with Qt 6.8.2.
- [x] Verified `:/main.qml`, `:/Calculator.qml`, the historical `:/Plot/ImpulseProperties.qml` alias, and representative font/audio/image/shader mappings.
- [x] Verified distinct generated type names for the top-level level meter, SPL meter, and visual windowing delegate; headless startup remains alive through QML shell construction.

**Dependencies:** Task 1

**Files likely touched:** `CMakeLists.txt`, `qml/CMakeLists.txt`, `src/main.cpp`

**Estimated scope:** Medium

## Task 3: Port native audio selection to CMake

**Description:** Select ALSA, CoreAudio, or WASAPI by host platform and preserve optional ASIO discovery outside the repository.

**Acceptance criteria:**
- [x] Linux links ALSA and compiles `alsa.cpp`.
- [ ] macOS links CoreAudio/AudioToolbox and compiles `coreaudio.cpp`.
- [ ] Windows links required system libraries and compiles WASAPI; ASIO is opt-in when a valid SDK path is supplied.

**Verification:**
- [x] Linux configure output identifies ALSA as the single required native backend.
- [ ] Platform builds compile their selected backend.

**Current evidence:** Qt 6.8.2/GCC 14.2 compiled `client.cpp` and `alsa.cpp` against ALSA 1.2.14. macOS and Windows checks remain assigned to Tasks 32 and 33.

**Dependencies:** Task 1

**Files likely touched:** `CMakeLists.txt`, `cmake/AudioBackends.cmake`, `src/audio/client.cpp`

**Estimated scope:** Medium

## Task 4: Port renderer selection to CMake

**Description:** Add `OSM_GRAPH_BACKEND` with OpenGL as the portable default and Metal as a macOS-only option, including shader compilation/resources.

**Acceptance criteria:**
- [ ] OpenGL defines `GRAPH_OPENGL` and compiles only OpenGL renderer sources.
- [ ] Metal defines `GRAPH_METAL`, compiles Objective-C++ sources and `.metal` shaders, and is rejected on non-macOS hosts.
- [x] Exactly one backend is selected.

**Verification:**
- [x] Configured OpenGL on Linux and verified CMake source parity with the qmake renderer lists; macOS/Windows remain pending.
- [ ] Configure Metal on macOS and confirm the metallib build dependency.

**Current evidence:** Linux emits only `GRAPH_OPENGL` and rejects `OSM_GRAPH_BACKEND=METAL`. The first renderer compilation reaches the expected Qt 6 header incompatibility assigned to Task 10 (`QtGui/QOpenGLFramebufferObject` moved out of Qt Gui).

**Dependencies:** Task 1

**Files likely touched:** `CMakeLists.txt`, `cmake/RenderBackends.cmake`, `src/chart/seriesitem.h`

**Estimated scope:** Medium

## Task 5: Add test, lint, install, and deployment foundations

**Description:** Enable CTest/Qt Test, expose QML linting, and establish install/deployment hooks that later packaging tasks can complete.

**Acceptance criteria:**
- [x] `BUILD_TESTING` controls test targets.
- [x] Qt warnings/deprecation diagnostics are enabled.
- [x] Install rules and `qt_generate_deploy_qml_app_script()` are present without running packaging during ordinary debug builds.

**Verification:**
- [x] `ctest --test-dir build-qt6 -N` lists the resource-manifest regression test, which passes.
- [x] `cmake --build build-qt6 --target all_qmllint` is available.
- [x] The generated install script stages the executable and invokes Qt's QML deployment script once the application builds.

**Dependencies:** Tasks 1-2

**Files likely touched:** `CMakeLists.txt`, `cmake/Deployment.cmake`, `tests/CMakeLists.txt`

**Estimated scope:** Medium

## Task 6: Capture remote variant conversion behavior

**Description:** Add Qt Test regression coverage for application-owned conversion of bool, integer, floating, string, color, and user-defined variants into remote JSON payloads before porting dispatch APIs.

**Acceptance criteria:**
- [x] Tests describe the serialized output for every currently handled metatype.
- [x] Tests fail if the conversion API is absent or the contract is perturbed.
- [x] No network sockets or hardware are required.

**Verification:**
- [x] Observed the new test fail before `remote/variantjson.h` existed, then implemented the minimum converter.
- [x] `ctest --test-dir build-qt6 --output-on-failure -R remote_variant_test` passes with Qt 6.8.2.

**Dependencies:** Task 5

**Files likely touched:** `tests/remote_variant_test.cpp`, `tests/CMakeLists.txt`, `src/remote/server.cpp`, `src/remote/server.h`

**Estimated scope:** Medium

## Task 7: Port server variant handling

**Description:** Replace removed/deprecated `QVariant::Type` dispatch in the remote server with documented Qt 6 metatype APIs without changing payloads.

**Acceptance criteria:**
- [x] Server conversion compiles without deprecated Qt 5 type APIs.
- [x] Task 6 payload expectations remain unchanged.

**Verification:**
- [x] `ctest --test-dir build-qt6 --output-on-failure -R remote_variant_test` passes with Qt 6.8.2.
- [x] Built `src/remote/server.cpp` with the target's `QT_DEPRECATED_WARNINGS` definition enabled.

**Dependencies:** Task 6

**Files likely touched:** `src/remote/server.cpp`, `src/remote/server.h`, `tests/remote_variant_test.cpp`

**Estimated scope:** Small

## Task 8: Port generator, item, and client variant handling

**Description:** Apply the proven metatype conversion pattern to the remaining remote/generator paths.

**Acceptance criteria:**
- [x] Generator remote, remote item, and remote client compile with Qt 6 metatype APIs.
- [x] Generator property payloads preserve existing values and types.

**Verification:**
- [x] Extended the conversion tests for long, double, and the legacy missing-alpha default; `remote_variant_test` passes.
- [x] Built `generatorremote.cpp`, `item.cpp`, and `remoteclient.cpp` with the target's `QT_DEPRECATED_WARNINGS` definition enabled.

**Dependencies:** Task 7

**Files likely touched:** `src/remote/generatorremote.cpp`, `src/remote/item.cpp`, `src/remote/remoteclient.cpp`, `tests/remote_variant_test.cpp`

**Estimated scope:** Medium

## Task 9: Resolve remaining bounded C++ Qt 6 compile failures

**Description:** Use compiler errors and Qt's porting guidance to fix remaining Core/Gui/Network incompatibilities in batches of no more than five source files per increment.

**Acceptance criteria:**
- [x] Each change is justified by a concrete compiler error or documented removed API.
- [x] No unrelated C++ modernization is mixed into the port.
- [x] A keep-going Qt 6.8.2 build compiled every non-renderer C++ source; remaining errors are isolated to Task 10's OpenGL files and the local ALSA link path.

**Verification:**
- [x] Built after each batch of no more than five source files, including regenerated AUTOMOC output.
- [x] `ctest --test-dir build-qt6 --output-on-failure` passes after each batch.
- [x] `settings_test` proves missing-value defaults persist, existing values win, and an omitted default remains invalid under Qt 6.

**Dependencies:** Tasks 3, 7-8

**Files likely touched:** Determined by Qt 6 compiler diagnostics; maximum five per increment.

**Estimated scope:** Repeated small increments

## Task 10: Port the OpenGL scene-graph integration

**Description:** Update application backend selection and framebuffer renderer state handling to Qt 6 APIs while preserving all chart renderers.

**Acceptance criteria:**
- [x] OpenGL backend is selected through `QQuickWindow::setGraphicsApi()`.
- [x] Renderer state is restored through `QQuickOpenGLUtils::resetOpenGLState()`.
- [ ] Every chart type renders without shader or context errors.

**Verification:**
- [x] Full Qt 6.8.2 OpenGL configuration builds and links on Linux.
- [x] Startup passes the removed Controls 1 and Graphical Effects modules and reaches live source-item construction; chart runtime verification remains pending.

**Dependencies:** Tasks 2, 4, 9

**Files likely touched:** `src/main.cpp`, `src/chart/opengl/seriesrenderer.cpp`, `src/chart/opengl/seriesrenderer.h`, `src/chart/opengl/seriesfbo.cpp`, `src/chart/opengl/seriesfbo.h`

**Estimated scope:** Medium

## Task 11: Port the optional Metal scene-graph integration

**Description:** Update the macOS Metal bridge and backend enum/API usage for Qt 6.8 without affecting the default OpenGL build.

**Acceptance criteria:**
- [ ] Metal sources and metallib compile with Qt 6.8/Xcode.
- [x] Backend selection uses `setGraphicsApi()` and native textures use `QSGMetalTexture::fromNative()`.
- [x] The full OpenGL build and test suite remain green after the Metal source changes.

**Verification:**
- [ ] Build and run `OSM_GRAPH_BACKEND=METAL` on macOS; unavailable on the current Linux host.
- [ ] Exercise all chart types and compare data/interaction behavior with OpenGL.

**Dependencies:** Task 10

**Files likely touched:** `src/chart/metal/seriesnode.h`, `src/chart/metal/seriesnode.mm`, `src/chart/metal/seriesitem.h`, `src/chart/metal/seriesitem.cpp`, `cmake/RenderBackends.cmake`

**Estimated scope:** Medium

## Task 12: Migrate project file dialogs

**Description:** Replace legacy Dialogs 1 properties with Qt Quick Dialogs 2 while preserving create/open/save/import, filters, folders, and recent-file updates.

**Acceptance criteria:**
- [x] Save uses `selectedFile`, `FileDialog.SaveFile`, and retains the default `.osm` suffix/filter.
- [x] Open/import use `selectedFile`; import uses `selectedNameFilter.index`.
- [x] Recent project folders read/write `currentFolder` and `selectedFile`.

**Verification:**
- [x] The affected QML compiles into the application, and Qt 6.8 `qmllint` exits successfully for `qml/main.qml` (application-context warnings remain).
- [ ] Manually save, open, import each supported format, and select a recent project.

**Dependencies:** Tasks 2, 9

**Files likely touched:** `qml/main.qml`, `qml/Calculator.qml`, `src/common/recentfilesmodel.cpp`, `src/common/recentfilesmodel.h`

**Estimated scope:** Medium

## Task 13: Replace the Controls 1 desktop menu

**Description:** Rebuild the top menu with Qt Quick Controls 2, retaining every action, check state, dynamic recent-project entry, and shortcut.

**Acceptance criteria:**
- [x] The desktop menu uses no Controls 1 or Controls 1 Styles import.
- [x] File/View/Help commands are Controls 2 `Action`s; dynamic recent files remain concrete inserted `MenuItem`s.
- [ ] Menu colors remain legible in light and dark modes.

**Verification:**
- [x] Qt 6.8 `qmllint` exits successfully for `qml/menu/Top.qml` (application-context warnings remain).
- [ ] Trigger every menu item and shortcut; verify checked states and recent-menu insertion/removal.

**Dependencies:** Task 12

**Files likely touched:** `qml/menu/Top.qml`, `qml/menu/Side.qml`, `qml/main.qml`

**Estimated scope:** Medium

## Task 14: Replace the Controls 1 split view and sidebar integration

**Description:** Migrate the chart splitter and adjacent shell components to Controls 2 while retaining chart count, saved sizes, double-click equalization, and responsive sidebar layout.

**Acceptance criteria:**
- [x] The vertical Controls 2 splitter retains one-to-three-chart visibility, minimum sizes, dragging, and double-click equalization behavior.
- [x] Existing chart height/type settings keys feed the Controls 2 preferred sizes and remain updated from actual chart sizes.
- [x] The responsive grid, narrow-window spans, sidebar stack, and shortcuts are unchanged and no longer import Controls 1.

**Verification:**
- [x] Qt 6.8 `qmllint` exits successfully for `Charts.qml`, `SideBar.qml`, and `main.qml` (application-context warnings remain).
- [x] Headless startup passes the migrated shell and remains alive for the 12-second smoke window.
- [x] A clean first-run settings directory now starts without typed-property `undefined` assignment errors.
- [ ] Resize/equalize charts, restart, and verify persisted layout at wide and narrow widths.

**Dependencies:** Task 13

**Files likely touched:** `qml/Charts.qml`, `qml/SideBar.qml`, `qml/SourceLayout.qml`, `qml/PropetiesBar.qml`

**Estimated scope:** Medium

## Task 15: Migrate chart effects and chart-level dialogs

**Description:** Replace removed Graphical Effects and legacy dialog imports used by the chart shell, preserving visual emphasis and chart property actions.

**Acceptance criteria:**
- [x] No `QtGraphicalEffects` or Dialogs 1 import remains in the chart shell.
- [x] The cursor's theme-aware halo uses Qt 6.8 `MultiEffect` with the original light/dark colors.
- [x] Chart property routing/type-change logic is unchanged, and chart image saving uses the Dialogs 2 save-file contract.

**Verification:**
- [x] Qt 6.8 `qmllint` exits successfully for `Chart.qml`, `ChartProperties.qml`, and `PropertiesOpener.qml` (application-context warnings remain).
- [x] Headless startup passes the migrated effect and remains alive through QML shell/source-item construction for the 12-second smoke window.
- [ ] Visually inspect active/inactive charts and open all chart-level properties.

**Dependencies:** Task 14

**Files likely touched:** `qml/Chart.qml`, `qml/ChartProperties.qml`, `qml/PropertiesOpener.qml`

**Estimated scope:** Medium

## Task 16: Migrate plot property dialogs, batch A

**Description:** Port the first bounded group of plot property components to Dialogs 2 and versionless Qt imports.

**Acceptance criteria:**
- [x] Each PNG save action retains its existing plot grab and URL-normalization callback while using Dialogs 2 `selectedFile`.
- [x] No versioned Qt or Dialogs 1 imports remain in the batch.

**Verification:**
- [x] Qt 6.8 `qmllint` exits successfully for all four files.
- [x] The full application builds, all three tests pass, and a clean-settings headless smoke run remains alive.
- [ ] Open and change representative properties for each plot.

**Dependencies:** Task 15

**Files likely touched:** `qml/Plot/RTAProperties.qml`, `qml/Plot/MagnitudeProperties.qml`, `qml/Plot/PhaseProperties.qml`, `qml/Plot/CoherenceProperties.qml`

**Estimated scope:** Medium

## Task 17: Migrate plot property dialogs, batch B

**Description:** Port the second bounded group of plot property components.

**Acceptance criteria:**
- [x] Each PNG save action retains its existing plot grab and URL-normalization callback while using Dialogs 2 `selectedFile`.
- [x] No versioned Qt or Dialogs 1 imports remain in the batch.

**Verification:**
- [x] Qt 6.8 `qmllint` exits successfully for all four files.
- [x] The full application builds and all three tests pass.
- [ ] Open and change representative properties for each plot.

**Dependencies:** Task 16

**Files likely touched:** `qml/Plot/GroupDelayProperties.qml`, `qml/Plot/PhaseDelayProperties.qml`, `qml/Plot/ImplulseProperties.qml`, `qml/Plot/StepProperties.qml`

**Estimated scope:** Medium

## Task 18: Migrate plot property dialogs, batch C

**Description:** Port the remaining plot property components.

**Acceptance criteria:**
- [x] Each PNG save action retains its existing plot grab and URL-normalization callback while using Dialogs 2 `selectedFile`.
- [x] No versioned Qt or Dialogs 1 imports remain anywhere under `qml/Plot`.

**Verification:**
- [x] Qt 6.8 `qmllint` exits successfully for all four files (standalone `SourceModel` context warnings remain for Spectrogram).
- [x] The full application builds and all three tests pass.
- [ ] Open and change representative properties for each plot.

**Dependencies:** Task 17

**Files likely touched:** `qml/Plot/SpectrogramProperties.qml`, `qml/Plot/CrestFactorProperties.qml`, `qml/Plot/NyquistProperties.qml`, `qml/Plot/LevelProperties.qml`

**Estimated scope:** Medium

## Task 19: Migrate source property dialogs, batch A

**Description:** Port measurement, equalizer, and stored-source dialog usage.

**Acceptance criteria:**
- [x] Calibration uses Dialogs 2 `OpenFile`; equalizer/stored exports retain their save callbacks and dynamic suffix dispatch through `selectedFile`.
- [x] The color picker seeds and accepts Qt 6.8 `ColorDialog.selectedColor` while preserving right-click color cycling.
- [x] No versioned Qt or Dialogs 1 imports remain in the batch.

**Verification:**
- [x] Qt 6.8 `qmllint` exits successfully for all four files (standalone application-context warnings remain).
- [x] The full application builds and all three tests pass.
- [ ] Exercise calibration/import/color workflows in each component.

**Dependencies:** Task 12

**Files likely touched:** `qml/source/MeasurementProperties.qml`, `qml/source/EqualizerProperties.qml`, `qml/source/StoredProperties.qml`, `qml/elements/ColorPicker.qml`

**Estimated scope:** Medium

## Task 20: Migrate source property dialogs, batch B

**Description:** Port union, standard-line, windowing, and remote property dialog usage.

**Acceptance criteria:**
- [x] The files contained no dialog instances; removing their unused Dialogs 1 imports leaves all property/color bindings unchanged.
- [x] No versioned Qt or Dialogs 1 imports remain in the batch.

**Verification:**
- [x] Qt 6.8 `qmllint` exits successfully for all four files (standalone application-context warnings remain).
- [x] The full application builds and all three tests pass.
- [ ] Exercise representative property changes for each component.

**Dependencies:** Task 19

**Files likely touched:** `qml/source/UnionProperties.qml`, `qml/source/StandardLineProperties.qml`, `qml/source/WindowingProperties.qml`, `qml/RemoteProperties.qml`

**Estimated scope:** Medium

## Task 21: Normalize generator and meter imports

**Description:** Convert a bounded set of top-level QML components to versionless Qt 6 imports without behavior changes.

**Acceptance criteria:**
- [x] Versionless imports resolve under Qt 6.8.
- [x] Generator and meter bindings/actions are unchanged; `EQPoints` retains its single drag key through the Qt 6 string-list form.

**Verification:**
- [x] Qt 6.8 `qmllint` exits successfully for all five files (standalone registered-type context warnings remain).
- [x] The full application builds and all three tests pass.
- [ ] Open generator and meter views and exercise their main controls.

**Dependencies:** Tasks 13-15

**Files likely touched:** `qml/About.qml`, `qml/EQPoints.qml`, `qml/Generator.qml`, `qml/GeneratorProperties.qml`, `qml/Meter.qml`

**Estimated scope:** Medium

## Task 22: Normalize shell and popup imports

**Description:** Convert shell overlays and popups to versionless Qt 6 imports.

**Acceptance criteria:**
- [ ] Versionless imports resolve under Qt 6.8.
- [ ] Messages, confirmations, shortcuts, and custom checkbox behavior remain unchanged.

**Verification:**
- [ ] `qmllint` passes.
- [ ] Trigger each popup/overlay in both themes.

**Dependencies:** Task 21

**Files likely touched:** `qml/Message.qml`, `qml/ModalDialog.qml`, `qml/MulticolorCheckBox.qml`, `qml/Shortcuts.qml`, `qml/Updater.qml`

**Estimated scope:** Medium

## Task 23: Normalize target and layout imports

**Description:** Convert the remaining top-level target/layout components to versionless Qt 6 imports.

**Acceptance criteria:**
- [ ] Versionless imports resolve under Qt 6.8.
- [ ] Target trace and SPL grid/meter behavior remains unchanged.

**Verification:**
- [ ] `qmllint` passes.
- [ ] Exercise target trace visibility/editing and SPL display.

**Dependencies:** Task 22

**Files likely touched:** `qml/TargetTrace.qml`, `qml/TargetTraceProperties.qml`, `qml/SPL/Grid.qml`, `qml/SPL/Meter.qml`, `qml/SPL/MeterProperties.qml`

**Estimated scope:** Medium

## Task 24: Normalize reusable element imports, batch A

**Description:** Convert the first group of reusable controls to versionless Qt 6 imports.

**Acceptance criteria:**
- [ ] Controls retain value, focus, selection, and validation behavior.
- [ ] Versionless imports resolve under Qt 6.8.

**Verification:**
- [ ] `qmllint` passes.
- [ ] Exercise each element through its consuming property panel.

**Dependencies:** Task 23

**Files likely touched:** `qml/elements/ColoredMenuItem.qml`, `qml/elements/DropDown.qml`, `qml/elements/FloatSpinBox.qml`, `qml/elements/GeneratorChannelSelect.qml`, `qml/elements/NameField.qml`

**Estimated scope:** Medium

## Task 25: Normalize reusable element imports, batch B

**Description:** Convert the remaining reusable controls to versionless Qt 6 imports.

**Acceptance criteria:**
- [ ] Controls retain selection, spin, and combo behavior.
- [ ] Versionless imports resolve under Qt 6.8.

**Verification:**
- [ ] `qmllint` passes.
- [ ] Exercise each element through its consuming property panel.

**Dependencies:** Task 24

**Files likely touched:** `qml/elements/Select.qml`, `qml/elements/SelectableSpinBox.qml`, `qml/elements/TitledCombo.qml`

**Estimated scope:** Small

## Task 26: Normalize source item imports, batch A

**Description:** Convert the first bounded group of source row components to versionless Qt 6 imports.

**Acceptance criteria:**
- [ ] Source rows retain selection, naming, visibility, and action behavior.
- [ ] Versionless imports resolve under Qt 6.8.

**Verification:**
- [ ] `qmllint` passes.
- [ ] Create and interact with each source type.

**Dependencies:** Tasks 20, 25

**Files likely touched:** `qml/source/Source.qml`, `qml/source/Measurement.qml`, `qml/source/Stored.qml`, `qml/source/Group.qml`, `qml/source/RemoteItem.qml`

**Estimated scope:** Medium

## Task 27: Normalize source item imports, batch B

**Description:** Convert the remaining source row components to versionless Qt 6 imports.

**Acceptance criteria:**
- [ ] Source rows retain selection, naming, visibility, and action behavior.
- [ ] Versionless imports resolve under Qt 6.8.

**Verification:**
- [ ] `qmllint` passes.
- [ ] Create and interact with each source type.

**Dependencies:** Task 26

**Files likely touched:** `qml/source/Filter.qml`, `qml/source/Equalizer.qml`, `qml/source/Union.qml`, `qml/source/Windowing.qml`, `qml/source/StandardLine.qml`

**Estimated scope:** Medium

## Task 28: Normalize remaining source property imports

**Description:** Convert source property files not already changed by dialog slices to versionless Qt 6 imports.

**Acceptance criteria:**
- [ ] All source property files use versionless supported imports.
- [ ] Group, filter, and remote-item properties behave as before.

**Verification:**
- [ ] `qmllint` passes.
- [ ] Open and modify each affected property panel.

**Dependencies:** Task 27

**Files likely touched:** `qml/source/GroupProperties.qml`, `qml/source/FilterProperties.qml`, `qml/source/RemoteItemProperties.qml`

**Estimated scope:** Small

## Task 29: Restore desktop packaging

**Description:** Complete install/deployment behavior for Linux, macOS, and Windows, preserving icons, desktop metadata, plist/entitlements, and runtime QML/plugins.

**Acceptance criteria:**
- [ ] CMake install produces a self-contained staging tree using Qt's deployment API.
- [ ] macOS bundle metadata/microphone usage and Windows/Linux icons are present.
- [ ] Packaging is not run as an unconditional post-link side effect.

**Verification:**
- [ ] Stage an install on each platform and launch it outside the build tree.
- [ ] Inspect platform metadata and required plugins/resources.

**Dependencies:** Tasks 5, 10-11, 28

**Files likely touched:** `cmake/Deployment.cmake`, `CMakeLists.txt`, `Info.plist`, `info.entitlements`, `OpenSoundMeter.desktop`

**Estimated scope:** Medium

## Task 30: Update Qt 6/CMake documentation

**Description:** Replace Qt 5/qmake instructions with exact Qt 6.8 configure, build, test, install, and backend-option commands.

**Acceptance criteria:**
- [ ] README identifies Qt 6.8 LTS and C++17.
- [ ] Contributor instructions cover all three platforms and optional Metal/ASIO inputs.
- [ ] Documentation contains no stale supported qmake workflow.

**Verification:**
- [ ] Execute documented commands on at least one platform.
- [ ] Search documentation for stale Qt 5/qmake claims.

**Dependencies:** Task 29

**Files likely touched:** `README.md`, `CONTRIBUTING`, `docs/download.md`, `docs/tools.md`

**Estimated scope:** Medium

## Task 31: Verify Linux workflows

**Description:** Build, lint, test, install, and manually exercise the approved workflow matrix with Qt 6.8 on Linux.

**Acceptance criteria:**
- [ ] ALSA devices enumerate and representative input/output streams start.
- [ ] All UI, project, chart, remote, settings, and shutdown workflows pass.
- [ ] Installed application launches outside the build tree.

**Verification:**
- [ ] Record exact commands, Qt/compiler versions, test results, and any hardware-limited checks below this task.

**Dependencies:** Tasks 29-30

**Files likely touched:** `tasks/todo.md`

**Estimated scope:** Small documentation update plus runtime verification

## Task 32: Verify macOS workflows

**Description:** Build and exercise both OpenGL and Metal configurations with Qt 6.8 on macOS.

**Acceptance criteria:**
- [ ] CoreAudio and microphone permission behavior work.
- [ ] OpenGL and Metal render all chart types.
- [ ] App bundle installs and launches with required resources.

**Verification:**
- [ ] Record exact commands, Qt/Xcode versions, test results, and signing/notarization limitations below this task.

**Dependencies:** Task 31

**Files likely touched:** `tasks/todo.md`

**Estimated scope:** Small documentation update plus runtime verification

## Task 33: Verify Windows workflows

**Description:** Build and exercise the Qt 6.8 Windows configuration, including WASAPI and optional ASIO when supplied.

**Acceptance criteria:**
- [ ] WASAPI devices enumerate and representative streams start.
- [ ] Deployed application launches with required Qt/QML plugins.
- [ ] ASIO compiles and enumerates when a valid SDK is supplied, or remains explicitly pending.

**Verification:**
- [ ] Record exact commands, Qt/compiler versions, test results, and ASIO availability below this task.

**Dependencies:** Task 32

**Files likely touched:** `tasks/todo.md`

**Estimated scope:** Small documentation update plus runtime verification

## Task 34: Retire qmake

**Description:** Remove the legacy build only after the CMake implementation passes all parity gates.

**Acceptance criteria:**
- [ ] No supported docs or tooling invoke qmake.
- [ ] qmake-only project files are removed.
- [ ] CMake source/resource parity is rechecked after removal.

**Verification:**
- [ ] Search the repository for `qmake`, `.pro`, and `.pri` references and classify any intentional historical references.
- [ ] Run clean configure/build/test/lint from a new build directory.

**Dependencies:** Tasks 31-33

**Files likely touched:** `OpenSoundMeter.pro`, `PVS-Studio.pri`, `README.md`, `CONTRIBUTING`

**Estimated scope:** Medium

## Task 35: Final review and simplification

**Description:** Apply the Agent Skills code-quality and simplification gates without expanding scope.

**Acceptance criteria:**
- [ ] Review covers correctness, maintainability, security, performance, and operability.
- [ ] Accidental complexity and dead compatibility scaffolding are removed only when tests prove behavior is preserved.
- [ ] No unrelated refactors or generated artifacts are present.

**Verification:**
- [ ] Review the complete diff and commit history.
- [ ] Run the full build, lint, tests, install, and applicable runtime matrix once after final changes.
- [ ] Confirm human approval before merge or release.

**Dependencies:** Task 34

**Files likely touched:** Only files with review findings; each fix remains a bounded increment.

**Estimated scope:** Repeated small increments
