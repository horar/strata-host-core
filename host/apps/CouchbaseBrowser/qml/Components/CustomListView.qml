import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12

ListView {

    signal clicked(int index)
    signal cancel(int index)

    property bool displaySelected: true
    property bool displayUnselected: true
    property bool displayCancelBtn: false
    property bool enableMouseArea: true
    property real space: 5 // use space instead of spacing

    delegate: delegate
    clip: true

    Component {
        id: delegate
        Item {
            id: delegateRoot
            visible: selected ? ListView.view.displaySelected : ListView.view.displayUnselected
            width: parent.width - 10
            height: visible ? 30 : 0
            anchors.horizontalCenter: parent.horizontalCenter
            Rectangle {
                width: parent.width
                height: 25
                color: "steelblue"
                opacity: selected ? 1 : mouseArea.containsMouse ? 1 : 0.8
                radius: 13
                border {
                    width: 1
                    color: selected ? "limegreen" : "transparent"
                }

                layer.enabled: true
                clip: true
                MouseArea {
                    id: mouseArea
                    enabled: delegateRoot.ListView.view.enableMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        selected = !selected
                        delegateRoot.ListView.view.clicked(index)
                    }
                }
                layer.effect: DropShadow {
                    transparentBorder: true
                    horizontalOffset: 5
                    verticalOffset: 3
                }
                Image {
                    id: cancelButton
                    visible: delegateRoot.ListView.view.displayCancelBtn
                    width: 12
                    height: 12
                    source: "../Images/cancelIcon_white.svg"
                    fillMode: Image.PreserveAspectFit
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onHoveredChanged: cancelButton.source = containsMouse ? "../Images/cancelIcon_red.svg" : "../Images/cancelIcon_white.svg"
                        onClicked: {
                            selected = false
                            delegateRoot.ListView.view.cancel(index)
                        }
                    }
                    anchors {
                        right: parent.right
                        rightMargin: 5
                        verticalCenter: parent.verticalCenter
                    }
                }
                Text {
                    anchors.centerIn: parent
                    anchors {
                        rightMargin: 25
                        leftMargin: 25
                    }
                    font.pixelSize: 15
                    color: "#eee"
                    text: channel
                }
            }
        }
    }
}

