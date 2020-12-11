import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0

Item {
    id: root
    width: typeMetric.width
    height: typeMetric.height

    property alias type: msgType.text
    property color typeColor: "#fff"

    SGText {
        id: leftSide
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: '['
        color: typeColor
        fontSizeMultiplier: fontMultiplier
    }

    SGText {
        id: msgType
        anchors.centerIn: parent
        fontSizeMultiplier: fontMultiplier
        color: typeColor
    }

    SGText {
        id: rightSide
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: ']'
        color: typeColor
        fontSizeMultiplier: fontMultiplier
    }

    TextMetrics {
        id: typeMetric
        text: ` [ warning ] `
        font.pixelSize: SGSettings.fontPixelSize * fontMultiplier
    }


    function getMsgColor(type){
        switch(type){
        case "debug": return "#00bcd4"
        case "warning": return "#c0ca33"
        case "error": return "red"
        case "info": return "#4caf50"
        }
    }

    onTypeChanged: {
        typeColor = getMsgColor(type)
    }

}
