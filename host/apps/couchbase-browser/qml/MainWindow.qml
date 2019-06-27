import QtQuick 2.0
import QtQuick.Layouts 1.12
Item {
    id: root
    anchors.fill: parent

    property alias content: bodyView.content

    Rectangle {
        id: background
        anchors.fill: parent
        color: "midnightblue"

        GridLayout {
            id: gridview
            anchors.fill: parent
            rows: 2
            columns: 2
            columnSpacing: 1
            rowSpacing: 1


            Rectangle {
                id: menuContainer
                Layout.preferredWidth: parent.width
                Layout.preferredHeight: 82
                Layout.row: 0
                Layout.columnSpan: 2
                color: "steelblue"

                SystemMenu {
                    id: mainMenuView
                    anchors {
                        fill: parent
                        bottomMargin: 10
                    }

                }
            }
            Rectangle {
                id: selectorContainer
                Layout.preferredWidth: 150
                Layout.preferredHeight: (parent.height - menuContainer.height)
                Layout.row: 1
                Layout.alignment: Qt.AlignTop
                color: "steelblue"

                TableSelector {
                    id: tableSelectorView
                }
                Image {
                    id: onLogo
                    width: 50
                    height: 50
                    source: "Images/OnLogo.png"
                    fillMode: Image.PreserveAspectCrop
                    anchors {
                        bottom: parent.bottom
                        bottomMargin: 20
                        horizontalCenter: parent.horizontalCenter
                    }
                }
            }
            Rectangle {
                id: bodyContainer
                Layout.preferredWidth: (parent.width - selectorContainer.width)
                Layout.preferredHeight: (parent.height - menuContainer.height)
                Layout.alignment: Qt.AlignTop
                color: "steelblue"
                BodyDisplay {
                    id: bodyView
                }
            }
        }
    }
}
