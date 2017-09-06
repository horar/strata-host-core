import QtQuick 2.0
//import Qtx11extras 1.0
import QtQuick.Extras 1.4
//import QtWinExtras 1.0 as Win
import QtGraphicalEffects 1.0

Item {
    id:blur
    width: parent.width;height: parent.height
    opacity: 0.85


    Image {
        id: gray_backgroud
        source: "gray-card.jpg"
        sourceSize: Qt.size(parent.width, parent.height)
        smooth: true
        visible: false
        width: parent.width;height: parent.height

    }

    FastBlur {
        anchors { fill: gray_backgroud}
        source: gray_backgroud
        radius: 100
        transparentBorder: true
    }
}
