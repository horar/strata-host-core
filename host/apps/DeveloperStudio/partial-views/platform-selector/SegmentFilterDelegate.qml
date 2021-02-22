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

    function onClicked() {
        Filters.setFilterActive(model.filterName, true)
        selected()
    }

    MouseArea {
        id: mouseArea
        anchors {
            fill: parent
        }
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.onClicked()
        }
    }

    RowLayout {
        id: row
        spacing: 0
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
            visible: model.iconSource !== ""
        }

        SGText {
            text: model.text
            Layout.fillWidth: true
            Layout.margins: 5
            elide: Text.ElideRight
        }
    }
}
