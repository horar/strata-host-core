pragma Singleton

import QtQuick 2.12

QtObject {
    id: root

    readonly property int basePixelSize: 12

/* sample:
    readonly property color gray: "#b2b1b1"
    readonly property color lightGray: "#dddddd"
    readonly property color light: "#ffffff"
    readonly property color blue: "#2d548b"
    property color mainColor: "red"//"#17a81a"
    readonly property color dark: "#222222"
    readonly property color mainColorDarker: Qt.darker(mainColor, 1.5)

    property int baseSize: 10

    readonly property int smallSize: 10
    readonly property int largeSize: 16

    property font myFont
    font.bold: true
    font.underline: false
    font.pixelSize: 14
    font.family: "arial"
*/
}
