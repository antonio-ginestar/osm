/**
 *  OSM
 *  Copyright (C) 2018  Pavel Smokotnin

 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls.Material

import OpenSoundMeter 1.0
import "qrc:/elements"

Item {
    id: storedProperties
    property var dataObject
    property var dataObjectData : dataObject.data
    property string saveas: "osm"
    readonly property real notesWidth: {
        var naturalWidth = notesMetrics.advanceWidth(ta.placeholderText);
        var lines = ta.text.split("\n");
        for (var i = 0; i < lines.length; ++i) {
            naturalWidth = Math.max(naturalWidth, notesMetrics.advanceWidth(lines[i]));
        }
        return naturalWidth + ta.leftPadding + ta.rightPadding + scrollTextArea.effectiveScrollBarWidth;
    }

    implicitHeight: propertiesLayout.implicitHeight

    GridLayout
    {
        id: propertiesLayout
        anchors.fill: parent
        columns: width >= controls.implicitWidth + scrollTextArea.Layout.minimumWidth + columnSpacing ? 2 : 1

        ColumnLayout {
            id: controls
            Layout.alignment: Qt.AlignTop
            Layout.minimumWidth: implicitWidth
            Layout.fillWidth: propertiesLayout.columns === 1
            Layout.maximumWidth: propertiesLayout.columns === 2 ? implicitWidth : Infinity

            RowLayout {
                Layout.fillWidth: true
                FloatSpinBox {
                    id: gainSpinBox
                    value: dataObjectData.gain
                    from: -30
                    to: 30
                    units: "dB"
                    onValueChanged: dataObjectData.gain = value
                    tooltiptext: qsTr("adjust gain")
                    Layout.alignment: Qt.AlignVCenter
                }

                FloatSpinBox {
                    id: delaySpinBox
                    value: dataObjectData.delay
                    from: -100
                    to: 100
                    units: "ms"
                    onValueChanged: dataObjectData.delay = value
                    tooltiptext: qsTr("adjust delay")
                    Layout.alignment: Qt.AlignVCenter
                }

                ColorPicker {
                    id: colorPicker

                    Layout.preferredWidth: 25
                    Layout.preferredHeight: 25
                    Layout.margins: 5

                    onColorChanged: {
                        dataObjectData.color = color
                    }
                    Component.onCompleted: {
                        colorPicker.color = dataObjectData.color
                    }
                }

                NameField {
                    id: nameField
                    clip: true
                    Layout.fillWidth: true
                    Layout.minimumWidth: implicitWidth
                    Layout.preferredWidth: Math.min(
                        Math.max(implicitWidth, nameMetrics.advanceWidth + leftPadding + rightPadding),
                        Math.max(implicitWidth, storedProperties.width - gainSpinBox.implicitWidth
                                 - delaySpinBox.implicitWidth - colorPicker.Layout.preferredWidth
                                 - 2 * colorPicker.Layout.margins - 3 * parent.spacing))
                    target: dataObject
                    Layout.alignment: Qt.AlignVCenter
                }

                TextMetrics {
                    id: nameMetrics
                    font: nameField.font
                    text: nameField.text
                }
            }
            RowLayout {

                Button {
                    text: "flip"
                    checkable: true
                    checked: dataObjectData.inverse
                    onCheckedChanged: dataObjectData.inverse = checked

                    Material.background: parent.Material.background

                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("inverse magnitude data")
                }

                Button {
                    text: "+/–"
                    checkable: true
                    checked: dataObjectData.polarity
                    onCheckedChanged: dataObjectData.polarity = checked

                    Material.background: parent.Material.background

                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("inverse polarity")
                }

                Button {
                    text: "100%"
                    checkable: true
                    checked: dataObjectData.ignoreCoherence
                    onCheckedChanged: dataObjectData.ignoreCoherence = checked

                    Material.background: parent.Material.background

                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("ignore coherence")
                }

                DropDown {
                    id: saveData
                    readonly property TextInput labelInput: contentItem as TextInput
                    displayText: qsTr("Save data as");
                    Layout.minimumWidth: Math.ceil(Math.max(saveLabelMetrics.advanceWidth, labelInput ? labelInput.contentWidth : 0))
                                         + leftPadding + rightPadding
                                         + (labelInput ? labelInput.leftPadding + labelInput.rightPadding : 0)

                    TextMetrics {
                        id: saveLabelMetrics
                        font: saveData.font
                        text: saveData.displayText
                    }

                    model: ["osm", "cal", "txt", "csv", "frd", "wav"]

                    onActivated: function() {
                        saveas = currentText;
                        fileDialog.open();
                    }

                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("export data")

                    enabled: dataObjectData.objectName === "Stored"
                    visible: dataObjectData.objectName === "Stored"
                }
            }
        }

        ScrollView {
            id: scrollTextArea
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: Math.min(storedProperties.width, storedProperties.notesWidth)
            Layout.minimumHeight: notesMetrics.lineSpacing * 4 + ta.topPadding + ta.bottomPadding
                                  + ta.topInset + ta.bottomInset
            Layout.preferredHeight: Layout.minimumHeight
            ScrollBar.vertical.policy: ScrollBar.AlwaysOn
            ScrollBar.vertical.interactive: false

            TextArea {
                id:ta
                placeholderText: qsTr("notes")
                text: dataObjectData.notes;
                onTextChanged: dataObjectData.notes = text;
                font.italic: true
                wrapMode: TextEdit.WrapAnywhere
                selectByMouse: true
                Keys.onEscapePressed: {
                    focus = false;
                }
            }
        }

        FontMetrics {
            id: notesMetrics
            font: ta.font
        }
    }

    FileDialog {
        id: fileDialog
        fileMode: FileDialog.SaveFile
        title: "Please choose a file's name"
        currentFolder: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]
        defaultSuffix: saveas
        onAccepted: {
            switch (saveas) {
                case "osm":
                    dataObjectData.save(fileDialog.selectedFile);
                    break;
                case "cal":
                    dataObjectData.saveCal(fileDialog.selectedFile);
                    break;
                case "txt":
                    dataObjectData.saveTXT(fileDialog.selectedFile);
                    break;
                case "csv":
                    dataObjectData.saveCSV(fileDialog.selectedFile);
                    break;
                case "frd":
                    dataObjectData.saveFRD(fileDialog.selectedFile);
                    break;
                case "wav":
                    dataObjectData.saveWAV(fileDialog.selectedFile);
                    break;
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
