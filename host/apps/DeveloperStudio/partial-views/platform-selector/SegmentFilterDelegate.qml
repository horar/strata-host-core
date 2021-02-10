import QtQuick 2.12
import QtQuick.Layouts 1.12

import tech.strata.theme 1.0
import tech.strata.sgwidgets 1.0

import "qrc:/js/platform_filters.js" as Filters

Rectangle {
    id: root
    implicitHeight: row.implicitHeight
    Layout.fillWidth: true
    color: mouseArea.containsMouse ? "#f2f2f2" : "white"

    property bool checked: false

    signal selected()

    MouseArea {
        id: mouseArea
        anchors {
            fill: parent
        }
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Filters.setFilterActive(model.filterName, true)
            root.selected()
        }
    }

    RowLayout {
        id: row
        spacing: 5
        anchors {
            fill: parent
        }

        SGIcon {
            id: icon
            implicitWidth: 25
            implicitHeight: 25
            source: model.iconSource
            mipmap: true
            iconColor: "black"
            Layout.leftMargin: 20
        }

        SGText {
            text: model.text
            Layout.fillWidth: true
            elide: Text.ElideRight
        }
    }
}
