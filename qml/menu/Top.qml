/**
 *  OSM
 *  Copyright (C) 2021  Pavel Smokotnin

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
import QtQuick
import QtQuick.Controls
import QtQml.Models
import QtQuick.Controls.Material
import OpenSoundMeterModule

MenuBar {
    id: menuBar

    Menu {
        title: qsTr("&File")
        Action {
            text: qsTr("&New")
            shortcut: StandardKey.New
            onTriggered: {
                dialog.title = qsTr("Create new workspace?")
                dialog.accepted.connect(closeAccepted);
                dialog.rejected.connect(closeRejected);
                dialog.open();
            }
            function closeAccepted() {
                applicationWindow.properiesbar.clear();
                sourceList.reset();
                closeRejected();
            }
            function closeRejected() {
                applicationWindow.dialog.accepted.disconnect(closeAccepted);
                applicationWindow.dialog.rejected.disconnect(closeRejected);
            }
        }
        Action {
            text: qsTr("&Save")
            shortcut: StandardKey.Save
            onTriggered: saveDialog.open();
        }
        Action {
            text: qsTr("&Open")
            shortcut: StandardKey.Open
            onTriggered: openDialog.open()
        }

        Menu {
            title: qsTr("Recent projects")
            id: recentFilesMenu

            RecentFilesModel {
                id: recentFilesModel
                settings: applicationSettings.getGroup("recentFiles");
                onProjectFolderChanged: {
                    let folder = recentFilesModel.projectFolder();
                    if (folder) {
                        openDialog.currentFolder = folder;
                        saveDialog.currentFolder = folder;
                    }
                }
            }

            Connections {
                target: sourceList
                function onLoaded(url) {
                    recentFilesModel.addUrl(url);
                }
            }

            Connections {
                target: saveDialog
                function onAccepted() {
                    recentFilesModel.storeProjectFolder(saveDialog.selectedFile);
                }
            }

            Connections {
                target: openDialog
                function onAccepted() {
                    recentFilesModel.storeProjectFolder(openDialog.selectedFile);
                }
            }

            Instantiator {
                model: recentFilesModel
                MenuItem {
                    text: model.fileName
                    onTriggered: sourceList.load(model.url)
                }
                onObjectAdded: recentFilesMenu.insertItem(index, object);
                onObjectRemoved: recentFilesMenu.removeItem(object)
            }

            MenuSeparator {
                visible: recentFilesModel.count > 0
            }

            MenuItem {
                text: "Clear menu"
                enabled: recentFilesModel.count > 0
                onTriggered: recentFilesModel.clear()
            }
        }
        Action {
            text: qsTr("&Import")
            shortcut: "Ctrl+I"
            onTriggered: importDialog.open()
        }
        Action {
            text: qsTr("&Add measurement")
            shortcut: "Ctrl+A"
            onTriggered: sourceList.addMeasurement();
        }
        Action {
            text: qsTr("&Add math source")
            shortcut: "Ctrl+M"
            onTriggered: sourceList.addUnion();
        }
        Action {
            text: qsTr("&Add standard line")
            shortcut: "Ctrl+L"
            onTriggered: sourceList.addStandardLine();
        }
        Action {
            text: qsTr("&Add filter")
            shortcut: "Ctrl+F"
            onTriggered: sourceList.addFilter();
        }
        Action {
            text: qsTr("&Add equalizer")
            shortcut: "Ctrl+E"
            onTriggered: sourceList.addEqualizer();
        }
        Action {
            text: qsTr("&Add windowing")
            shortcut: "Ctrl+W"
            onTriggered: sourceList.addWindowing();
        }
        Action {
            text: qsTr("&Add Group")
            shortcut: "Ctrl+0"
            onTriggered: sourceList.addGroup();
        }
        Action {
            text: qsTr("&Show target")
            shortcut: "Ctrl+T"
            checkable: true
            checked: targetTraceModel.show
            onCheckedChanged: targetTraceModel.show = checked
        }
        Action {
            text: qsTr("Quit")
            shortcut: StandardKey.Quit
            onTriggered: applicationWindow.close();
        }
    }
    Menu {
        title: qsTr("&View")
        Action {
            id: darkModeSelect
            text: qsTr("&Dark Mode")
            shortcut: "Ctrl+D"
            checkable: true
            checked: applicationAppearance.darkMode
            onCheckedChanged: {
                applicationAppearance.darkMode = darkModeSelect.checked;
            }
        }
        Action {
            id: calculator
            text: qsTr("&Calculator")
            shortcut: "Ctrl+K"
            checkable: false
            onTriggered: {
                applicationWindow.properiesbar.open(null, "qrc:/Calculator.qml");
            }
        }
        Action {
            id: experimentFunctions
            text: qsTr("&Experiment functions")
            checkable: true
            checked: applicationAppearance.experimentFunctions
            onCheckedChanged: {
                applicationAppearance.experimentFunctions = experimentFunctions.checked;
            }
        }
    }

    Menu {
        title: qsTr("&Help")
        Action {
            text: qsTr("&Shortcuts")
            shortcut: "F1"
            checkable: false
            onTriggered: shortcutsPopup.open();
        }
        Action {
            text: qsTr("About")
            onTriggered: aboutpopup.open();
            shortcut: "F2"
        }
        Action {
            text: qsTr("Check for update")
            shortcut: "F3"
            onTriggered: update.show();
        }
    }
}
