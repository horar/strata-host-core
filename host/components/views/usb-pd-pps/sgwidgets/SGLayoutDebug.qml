import QtQuick 2.9

Rectangle {
    color: Qt.rgba(Math.random()*0.5 + 0.25, Math.random()*0.5 + 0.25, Math.random()*0.5 + 0.25, 1)
    opacity: .2
    anchors {
        fill: parent
    }
    z:20
    visible: false
}
