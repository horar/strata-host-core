import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

Item {
    id: item1
    width: 700

    Rectangle {
        id: redRectangle
        x: 27
        y: 87
        width: 200
        height: 200
        color: "#c20101"
    }

    Rectangle {
        id: greenRectangle
        x: 248
        y: 87
        width: 200
        height: 200
        color: "#04d254"
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Rectangle {
        id: blueRectangle
        x: 466
        y: 87
        width: 200
        height: 200
        color: "#0f03ce"
    }

    Button {
        id: button
        x: 313
        y: 382
        text: qsTr("Fade")
        font.pointSize: 36
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Connections {
        target: button
        onClicked:{ redRectangle.opacity = 0
                    greenRectangle.opacity = 0
                    blueRectangle.opacity = .5
        }
    }
}
