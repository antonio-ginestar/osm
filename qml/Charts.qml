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
import QtQuick
import QtQuick.Controls

Item {
    id: chartsLayout
    property int count: applicationSettings.value("layout/charts/count", 1)

    Component.onCompleted: {
        chartsLayout.onCountChanged.connect(updateCount);
    }

    function autoHeight() {
        const chartHeight = chartsLayout.height / count;
        first.SplitView.preferredHeight = chartHeight;
        second.SplitView.preferredHeight = chartHeight;
        third.SplitView.preferredHeight = chartHeight;
    }

    function updateCount() {
        autoHeight();
        applicationSettings.setValue("layout/charts/count", count)
    }

    SplitView {
        id: sv
        anchors.fill: parent
        orientation: Qt.Vertical
        readonly property int minimumChartHeight: 100

         Chart {
             id: first
             SplitView.minimumHeight: sv.minimumChartHeight
             SplitView.preferredHeight: applicationSettings.value("layout/charts/1/height", chartsLayout.height)
             SplitView.fillHeight: true
             onHeightChanged: applicationSettings.setValue("layout/charts/1/height", height)
             type: applicationSettings.value("layout/charts/1/type", "Spectrum")
             onTypeChanged: applicationSettings.setValue("layout/charts/1/type", type)

             Component.onCompleted: {
                 settings = applicationSettings.getGroup("layout/charts/1");
             }
         }

         Chart {
             id: second
             visible: chartsLayout.count > 1
             SplitView.minimumHeight: sv.minimumChartHeight
             SplitView.preferredHeight: applicationSettings.value("layout/charts/2/height", chartsLayout.height / 2)
             onHeightChanged: applicationSettings.setValue("layout/charts/2/height", height)
             type: applicationSettings.value("layout/charts/2/type", "Spectrum")
             onTypeChanged: applicationSettings.setValue("layout/charts/2/type", type)

             Component.onCompleted: {
                 settings = applicationSettings.getGroup("layout/charts/2");
             }
         }

         Chart {
             id: third
             visible: chartsLayout.count > 2
             SplitView.minimumHeight: sv.minimumChartHeight
             SplitView.preferredHeight: applicationSettings.value("layout/charts/3/height", chartsLayout.height / 3)
             onHeightChanged: applicationSettings.setValue("layout/charts/3/height", height)
             type: applicationSettings.value("layout/charts/3/type", "Spectrum")
             onTypeChanged: applicationSettings.setValue("layout/charts/3/type", type)

             Component.onCompleted: {
                 settings = applicationSettings.getGroup("layout/charts/3");
             }
         }

         SystemPalette { id: pal }
         handle: Rectangle {
             implicitWidth: 1
             implicitHeight: 5
             color: Qt.darker(pal.window, 1.5)

             Rectangle {
                 anchors.verticalCenter: parent.verticalCenter
                 width: parent.width
                 height: 1
                 color: parent.color
             }

             TapHandler {
                 onDoubleTapped: autoHeight()
             }
         }
     }

}
