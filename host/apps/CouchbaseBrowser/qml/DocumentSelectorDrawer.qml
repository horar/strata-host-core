import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import "Components"
ColumnLayout {
    id: root   

    property alias model: listView.model
    property alias currentIndex: listView.currentIndex

    function clearSearch() {
        searchbox.userInput = ""
    }

    UserInputBox {
        id: searchbox
        Layout.preferredWidth: parent.width - 20
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: 10

        showButton: true
        iconSize: 12
        color: "darkred"
        path: "Images/cancel-icon.svg"
        placeholderText: "Search"
        onClicked: {
            searchbox.userInput = ""
        }
    }

    ListView {
        id: listView
        Layout.fillHeight: true
        Layout.preferredWidth: parent.width - 10
        Layout.alignment: Qt.AlignRight
        Layout.bottomMargin: 10

        clip: true
        model: []
        delegate: Component {
            Rectangle  {
                width: parent.width - 10
                height: visible ? 30 : 0

                visible: model.modelData.toLowerCase().includes(searchbox.userInput.toLowerCase())
                border.width: 1
                border.color: "#393e46"
                color: listView.currentIndex === index ? "#612b00" : mouseArea.containsMouse ? "#8c4100" : "#b55400"
                radius: 3

                Text {
                    width: parent.width - 10
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight

                    text: model.modelData
                    color: "#eee"
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent

                    onClicked: listView.currentIndex = index
                }
            }
        }
        ScrollBar.vertical: ScrollBar {
            id: scrollBar
            width: 10

            policy: ScrollBar.AsNeeded
        }
    }
}
