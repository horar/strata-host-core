import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Item {
    property alias model: treeView.model
    Component {
        id: recursiveComponent
        Column {
            width: treeView.width
            leftPadding: depth * 4
            Component.onCompleted: {
                if (isDir) {
                    console.info(JSON.stringify(childNodes[0]))
                }

            }

            Row {
                width: parent.width
                height: 30

                Text {
                    text: filename
                    font.pointSize: 10
                }

            }

            Repeater {
                model: childNodes
                delegate: recursiveComponent
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        ListView {
            id: treeView
            Layout.fillWidth: true
            Layout.fillHeight: true
            delegate: recursiveComponent
        }
    }
}

