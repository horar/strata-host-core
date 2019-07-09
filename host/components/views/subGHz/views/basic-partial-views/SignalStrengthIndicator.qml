import QtQuick 2.9
import QtQuick.Controls 2.2

Rectangle {
    id: root
    width: root.height
    color:"transparent"

    property int signalStrength:1       //number of bars shown in green
    property var barWidth: root.width/5

    Rectangle {
        id: bar1
        height: root.height/4
        width: barWidth

        anchors {
            left: root.left
            bottom: root.bottom
        }

        color: (signalStrength >=1) ? "yellow" : "black"
    }

    Rectangle {
        id: bar2
        height: root.height/2
        width: barWidth

        anchors {
            left: bar1.right
            leftMargin: 5
            bottom: root.bottom
        }

        color: (signalStrength >=2) ? "yellow" : "black"
    }

    Rectangle {
        id: bar3
        height: .75*root.height
        width: barWidth

        anchors {
            left: bar2.right
            leftMargin: 5
            bottom: root.bottom
        }

        color: (signalStrength >=3) ? "yellow" : "black"
    }
    Rectangle {
        id: bar4
        height: root.height
        width: barWidth

        anchors {
            left: bar3.right
            leftMargin: 5
            bottom: root.bottom
        }

        color: (signalStrength >=4) ? "yellow" : "black"
    }
}
