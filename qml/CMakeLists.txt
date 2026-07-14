set(OSM_QML_FILES
    qml/main.qml
    qml/About.qml
    qml/Calculator.qml
    qml/Chart.qml
    qml/ChartProperties.qml
    qml/Charts.qml
    qml/EQPoints.qml
    qml/Generator.qml
    qml/GeneratorProperties.qml
    qml/Message.qml
    qml/Meter.qml
    qml/ModalDialog.qml
    qml/MulticolorCheckBox.qml
    qml/PropertiesOpener.qml
    qml/PropetiesBar.qml
    qml/RemoteProperties.qml
    qml/Shortcuts.qml
    qml/SideBar.qml
    qml/SourceLayout.qml
    qml/TargetTrace.qml
    qml/TargetTraceProperties.qml
    qml/Updater.qml
    qml/Plot/CoherenceProperties.qml
    qml/Plot/CrestFactorProperties.qml
    qml/Plot/GroupDelayProperties.qml
    qml/Plot/ImplulseProperties.qml
    qml/Plot/LevelProperties.qml
    qml/Plot/MagnitudeProperties.qml
    qml/Plot/NyquistProperties.qml
    qml/Plot/PhaseDelayProperties.qml
    qml/Plot/PhaseProperties.qml
    qml/Plot/RTAProperties.qml
    qml/Plot/SpectrogramProperties.qml
    qml/Plot/StepProperties.qml
    qml/SPL/Grid.qml
    qml/SPL/Meter.qml
    qml/SPL/MeterProperties.qml
    qml/elements/ColorPicker.qml
    qml/elements/ColoredMenuItem.qml
    qml/elements/DropDown.qml
    qml/elements/FloatSpinBox.qml
    qml/elements/GeneratorChannelSelect.qml
    qml/elements/NameField.qml
    qml/elements/Select.qml
    qml/elements/SelectableSpinBox.qml
    qml/elements/TitledCombo.qml
    qml/menu/Side.qml
    qml/menu/Top.qml
    qml/source/Equalizer.qml
    qml/source/EqualizerProperties.qml
    qml/source/Filter.qml
    qml/source/FilterProperties.qml
    qml/source/Group.qml
    qml/source/GroupProperties.qml
    qml/source/Measurement.qml
    qml/source/MeasurementProperties.qml
    qml/source/RemoteItem.qml
    qml/source/RemoteItemProperties.qml
    qml/source/Source.qml
    qml/source/StandardLine.qml
    qml/source/StandardLineProperties.qml
    qml/source/Stored.qml
    qml/source/StoredProperties.qml
    qml/source/Union.qml
    qml/source/UnionProperties.qml
    qml/source/Windowing.qml
    qml/source/WindowingProperties.qml
)

foreach(qml_file IN LISTS OSM_QML_FILES)
    string(REGEX REPLACE "^qml/" "" qml_resource_alias "${qml_file}")
    set_source_files_properties("${qml_file}" PROPERTIES
        QT_RESOURCE_ALIAS "${qml_resource_alias}"
    )
endforeach()

set_source_files_properties(qml/Plot/ImplulseProperties.qml PROPERTIES
    QT_RESOURCE_ALIAS Plot/ImpulseProperties.qml
)

qt_add_qml_module(OpenSoundMeter
    URI OpenSoundMeterModule
    VERSION 1.0
    RESOURCE_PREFIX /
    NO_RESOURCE_TARGET_PATH
    QML_FILES
        ${OSM_QML_FILES}
)
