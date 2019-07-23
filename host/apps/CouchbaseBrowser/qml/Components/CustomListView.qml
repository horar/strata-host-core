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
    property color dropShadowColor: "#aa000000"
    property color glowColor: "#ffd8a7"
    property color gradientStop1: "#843900"
    property color gradientStop2: "#B55400"
    property color gradientStop3: "#E86B12"
    property color fontColor: "#eee"

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
            DropShadow {
                anchors.fill: delegateContent
                source: delegateContent
                horizontalOffset: 5
                verticalOffset: 5
                spread: 0
                color: dropShadowColor
            }
            Rectangle {
                id: delegateContent
                width: parent.width
                height: 25
                radius: 13
                gradient: Gradient {
                    GradientStop {position: 0; color: gradientStop1}
                    GradientStop {position: 0.5; color: gradientStop2}
                    GradientStop {position: 1; color: gradientStop3}
                }
                layer.enabled: selected
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
                layer.effect: Glow {
                    samples: 15
                    color: glowColor
                    transparentBorder: true
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
                    color: fontColor
                    text: channel
                }
            }
        }
    }
}

