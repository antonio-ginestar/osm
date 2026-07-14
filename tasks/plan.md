# Implementation Plan: Qt 6.8 LTS Port

## Overview

Replace the Qt 5.15/qmake build with a Qt 6.8 LTS CMake build while preserving Open Sound Meter's Linux, macOS, and Windows behavior. The migration proceeds risk-first: prove the modern build and QML resource model, restore native audio and rendering, migrate removed C++ and QML APIs in small workflow slices, then verify all target platforms before retiring qmake.

Specification: [`docs/qt6-port-spec.md`](../docs/qt6-port-spec.md)

## Architecture Decisions

- Require Qt 6.8 and C++17; do not combine this migration with a language-standard upgrade.
- Use `qt_add_executable()`, `qt_standard_project_setup(REQUIRES 6.8)`, and `qt_add_qml_module()`.
- Put QML module declaration in `qml/CMakeLists.txt` so existing root-relative `qrc:/...` URLs can be preserved with minimal source churn.
- Split CMake concerns into source inventory, native audio, rendering, and deployment helpers.
- Keep custom ALSA/CoreAudio/WASAPI audio implementations and optional external ASIO integration.
- Keep OpenGL as the default renderer and Metal as an opt-in macOS backend.
- Use Qt Quick Controls 2 and Qt Quick Dialogs 2. Prefer Qt 6-native effects; use `Qt5Compat.GraphicalEffects` only if a visually equivalent Qt 6 effect cannot preserve behavior without disproportionate redesign.
- Preserve manual `qmlRegisterType()` registrations during the port; automatic QML type registration is a separate modernization.
- Preserve serialization and network payload shapes, guarded by focused Qt Test regression coverage where the current architecture permits.
- Make local atomic commits only after a buildable/tested increment, as required by the approved Agent Skills workflow.

## Dependency Graph

```text
CMake application target
    ├── QML module and resources
    ├── native audio selection
    ├── OpenGL / Metal renderer selection
    └── test and lint targets
            │
            ├── Qt 6 C++ API migration
            ├── Qt 6 renderer migration
            └── QML workflow migration
                    │
                    └── packaging and three-platform verification
                            │
                            └── qmake retirement
```

## Task List

### Phase 1: Build Foundation

- [x] Task 1: Add the Qt 6.8 CMake application target and source inventory.
- [x] Task 2: Add the QML module and preserve application resource URLs.
- [ ] Task 3: Port Linux, macOS, and Windows native audio selection to CMake.
- [ ] Task 4: Port OpenGL and optional Metal build selection to CMake.
- [ ] Task 5: Add CTest, Qt Test, QML lint, install, and deployment foundations.

### Checkpoint: Foundation

- [ ] A Qt 6.8 kit configures the project without qmake.
- [ ] CMake selects exactly one audio backend and one chart backend.
- [ ] QML and non-QML resources are present at their expected resource URLs.
- [ ] Test and lint targets are discoverable.

### Phase 2: C++ and Renderer Compatibility

- [ ] Task 6: Add regression tests for variant-to-JSON remote payload conversion.
- [ ] Task 7: Port server-side variant type handling to Qt 6.
- [ ] Task 8: Port generator/item/client variant type handling to Qt 6.
- [ ] Task 9: Resolve remaining Qt Core/Gui/Network Qt 6 compile failures in bounded batches.
- [ ] Task 10: Port the OpenGL scene-graph integration to Qt 6.
- [ ] Task 11: Port and verify the optional macOS Metal scene-graph integration.

### Checkpoint: C++ Core

- [ ] The C++ target builds with Qt deprecation warnings enabled.
- [ ] Remote compatibility tests pass.
- [ ] The application reaches QML engine startup with the OpenGL backend.
- [ ] The Metal target compiles on macOS or is explicitly reported pending for lack of a runner.

### Phase 3: Removed QML APIs and User Workflows

- [ ] Task 12: Migrate application file dialogs and project file workflows.
- [ ] Task 13: Replace the Controls 1 desktop menu while preserving actions and shortcuts.
- [ ] Task 14: Replace the Controls 1 chart split view and sidebar integration.
- [ ] Task 15: Migrate chart effects and chart-level dialog usage.
- [ ] Task 16: Migrate plot property dialogs, batch A.
- [ ] Task 17: Migrate plot property dialogs, batch B.
- [ ] Task 18: Migrate plot property dialogs, batch C.
- [ ] Task 19: Migrate source property dialogs, batch A.
- [ ] Task 20: Migrate source property dialogs, batch B.
- [ ] Task 21: Normalize top-level generator and meter QML imports.
- [ ] Task 22: Normalize shell and popup QML imports.
- [ ] Task 23: Normalize target/source-layout QML imports.
- [ ] Task 24: Normalize reusable element QML imports, batch A.
- [ ] Task 25: Normalize reusable element and SPL imports, batch B.
- [ ] Task 26: Normalize source item QML imports, batch A.
- [ ] Task 27: Normalize source item QML imports, batch B.
- [ ] Task 28: Normalize remaining source property QML imports.

### Checkpoint: QML Workflows

- [ ] `all_qmllint` passes without removed-module imports.
- [ ] Application startup has no QML load errors.
- [ ] Menus, shortcuts, split charts, source panels, and property dialogs work.
- [ ] Create/open/save/import and recent-project workflows preserve their data flow.

### Phase 4: Packaging, Verification, and Retirement

- [ ] Task 29: Restore desktop metadata, icons, installation, and Qt deployment scripts.
- [ ] Task 30: Update developer and user build documentation for Qt 6/CMake.
- [ ] Task 31: Run and record the Linux workflow verification matrix.
- [ ] Task 32: Run and record the macOS workflow verification matrix, including Metal.
- [ ] Task 33: Run and record the Windows workflow verification matrix, including optional ASIO when available.
- [ ] Task 34: Retire the qmake build after all parity gates pass.
- [ ] Task 35: Perform final code-quality, simplification, and scope review.

### Checkpoint: Complete

- [ ] Clean Qt 6.8 builds pass on Linux, macOS, and Windows.
- [ ] Tests and QML lint pass on all available runners.
- [ ] The specification's workflow matrix has been exercised.
- [ ] No Qt 5-only imports, qmake build entry points, generated output, or secrets remain.
- [ ] Documentation describes only the supported Qt 6/CMake build.
- [ ] Human review is complete before merge or release.

## Risks and Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| No Qt 6.8 kit is installed in the current environment | High | Land configuration in small slices; obtain a Qt 6.8 kit or use platform CI before declaring any build task complete. |
| Controls 1 menu and SplitView behavior differs in Controls 2 | High | Migrate workflows separately, retain shortcuts/actions, and verify resizing and checked states at runtime. |
| OpenGL scene-graph integration changed in Qt 6 | High | Port early, use documented Qt 6 APIs, and verify every chart type before UI polish. |
| Custom Metal code depends on scene-graph internals | High | Keep Metal isolated and optional; compile/test it only on a macOS Qt 6.8 runner and ask before removal. |
| CMake source inventory misses a platform file or resource | Medium | Mirror qmake lists explicitly and add configure-time/platform assertions. |
| Variant metatype changes alter remote JSON | High | Capture current payload behavior in tests before changing type dispatch. |
| Native audio cannot be exercised in headless CI | Medium | Compile in CI and perform device enumeration/stream checks on real desktops. |
| ASIO SDK and signing assets are unavailable | Medium | Keep integration conditional and report verification as pending rather than committing proprietary assets. |
| Qt 6 native controls cause unavoidable visual differences | Low | Preserve layout, state, and actions; accept minor platform-native rendering differences per the spec. |

## Verification Strategy

- After every implementation task: inspect the diff, scan for secrets, run the narrow test/lint/build target affected, then commit only if green.
- After every phase: run `cmake --build build --parallel`, `cmake --build build --target all_qmllint`, and `ctest --test-dir build --output-on-failure` when a Qt 6.8 kit is available.
- At final verification: exercise the manual workflow matrix on all three desktop platforms and retain evidence in `tasks/todo.md` or CI logs.
- Do not repeat a successful command unless source or configuration has changed since that run.

## Open Execution Dependencies

- A discoverable Qt 6.8 desktop kit is required to turn the current static planning work into compiler evidence.
- macOS and Windows runners or machines are required for their native backend verification.
- Optional ASIO verification requires a separately supplied ASIO SDK; it will not be added to the repository.
