import QtQuick 2.9

Item {
    id: root
    anchors {
        fill: parent
    }

    Image {
        id: background
        source: "qrc:/images/strata-logo.svg"
        height: 0.6 * root.height
        width: 2 * height
        anchors {
            centerIn: root
        }
        opacity: .05
    }

    Column {
        id: column
        spacing: 40
        width: root.width
        anchors {
            verticalCenter: root.verticalCenter
        }

        Text {
            id: majorText
            text: "<b>This platform is incompatible with your version of Strata.</b>"
            font {
                pixelSize: 20
            }
            color: "#777"
            anchors {
                horizontalCenter: column.horizontalCenter
            }
        }

        Text {
            id: minorText
            text: 'Please upgrade to the latest version of strata: <a href="http://www.onsemi.com/strata">onsemi.com/strata</a>'
            font {
                pixelSize: 15
            }
            color: "#777"
            anchors {
                horizontalCenter: column.horizontalCenter
            }
            onLinkActivated: Qt.openUrlExternally(link)
            linkColor: "#777"

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
            }
        }
    }
}
