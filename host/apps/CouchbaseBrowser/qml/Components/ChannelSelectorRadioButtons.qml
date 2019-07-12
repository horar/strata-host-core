import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.3
Item {
    RowLayout {
        id: selectorContainer
        width: parent.width
        height: 30
        RadioButton {
            id: pushButton
            Layout.preferredHeight: 30
            Layout.preferredWidth: 30
            Layout.alignment: Qt.AlignCenter
            Label {
                id: pushLabel
                text: "Push"
                color: "#eee"
                anchors {
                    bottom: parent.top
                    horizontalCenter: parent.horizontalCenter
                }
            }
            onClicked: {
                rep_type = "push"
            }
        }

        RadioButton {
            id: pullButton
            Layout.preferredHeight: 30
            Layout.preferredWidth: 30
            checked: true
            Layout.alignment: Qt.AlignCenter
            Label {
                id: pullLabel
                text: "Pull"
                color: "#eee"
                anchors {
                    bottom: parent.top
                    horizontalCenter: parent.horizontalCenter
                }
            }
            onClicked: rep_type = "pull"
        }
        RadioButton {
            id: pushAndPullButton
            Layout.preferredHeight: 30
            Layout.preferredWidth: 30
            Layout.alignment: Qt.AlignCenter
            Label {
                id: pushAndPullLabel
                text: "Both"
                color: "#eee"
                anchors {
                    bottom: parent.top
                    horizontalCenter: parent.horizontalCenter
                }
            }
            onClicked: rep_type = "pushpull"
        }
    }
}


