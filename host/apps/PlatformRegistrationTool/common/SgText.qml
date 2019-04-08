import QtQuick 2.12

Text {
    id: text

    property bool hasAlternativeColor: false
    property color normalColor: "black"
    property color alternativeColor: "white"
    property real fontSizeMultiplier: 1.0

    font.pixelSize: Qt.application.font.pixelSize * fontSizeMultiplier
    color: hasAlternativeColor ? alternativeColor : normalColor
}
