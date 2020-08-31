import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.12

import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

TextField {
    id: field
    placeholderText: ""
    selectByMouse: true
    maximumLength: 256
    Layout.fillWidth: true
    font {
        pixelSize: 15
        family: Fonts.franklinGothicBook
    }
    selectionColor:"lightgrey"

    property bool valid: field.text !== ""
    property alias showIcon: validIcon.visible

    background: Item {
        id: backgroundContainer
        implicitHeight: 32

        Rectangle {
            id: background
            anchors.fill: backgroundContainer
            visible: false
        }

        DropShadow {
            anchors.fill: background
            source: background
            horizontalOffset: 0
            verticalOffset: 2
            radius: 5.0
            samples: 10
            color: "#40000000"
        }
    }

    SGIcon {
        id: validIcon
        source: field.valid ? "qrc:/sgimages/check.svg" : "qrc:/sgimages/asterisk.svg"
        iconColor: field.valid ? "#30c235" : "#ddd"
        anchors {
            top: field.top
            topMargin: 5
            rightMargin: 5
            right: field.right
        }
        height: field.valid ? field.height * .33 : field.height * .25
        width: height
    }
}
