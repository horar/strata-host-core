import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12

import tech.strata.sgwidgets 1.0

ListView {

    delegate: delegate
    clip: true

    signal clicked(int index)
    signal cancel(int index)

    property bool displaySelected: true
    property bool displayUnselected: true
    property bool displayCancelBtn: false
    property bool enableMouseArea: true
    property color glowColor: "#f3f9fb"
    property color gradientStop1: "#843900"
    property color gradientStop2: "#B55400"
    property color gradientStop3: "#E86B12"
    property color fontColor: "#eee"
    property string searchKeyword: ""
    property real space: 3 // use space instead of spacing
    Component {
        id: delegate
        Item {
            id: delegateRoot
            width: ListView.view.width - 20
            height: visible ? 30 : 0
            anchors.horizontalCenter: ListView.view.horizontalCenter

            visible: containsKeyword ? (selected ? displaySelected : displayUnselected) : false

            property bool containsKeyword: model.text.toLowerCase().includes(ListView.view.searchKeyword.toLowerCase())
            property bool displaySelected: ListView.view.displaySelected
            property bool displayUnselected: ListView.view.displayUnselected

            Rectangle {
                id: delegateContent
                width: parent.width
                height: 25

                radius: 13
                layer.enabled: selected
                clip: true
                layer.effect: Glow {
                    samples: 15
                    color: glowColor
                    transparentBorder: true
                }
                gradient: Gradient {
                    GradientStop {position: 0; color: mouseArea.enabled && mouseArea.containsMouse ? Qt.lighter(gradientStop1, 1.5) : gradientStop1 }
                    GradientStop {position: 0.5; color: mouseArea.enabled && mouseArea.containsMouse ? Qt.lighter(gradientStop2, 1.5) : gradientStop2}
                    GradientStop {position: 1; color: mouseArea.enabled && mouseArea.containsMouse ? Qt.lighter(gradientStop3,1.5) : gradientStop3}
                }
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent

                    hoverEnabled: true
                    enabled: delegateRoot.ListView.view.enableMouseArea
                    onClicked: {
                        selected = !selected
                        delegateRoot.ListView.view.clicked(index)
                    }
                }
                SGIcon {
                    id: cancelButton
                    width: 12
                    height: 12
                    anchors {
                        right: parent.right
                        rightMargin: 5
                        verticalCenter: parent.verticalCenter
                    }

                    visible: delegateRoot.ListView.view.displayCancelBtn
                    source: "../Images/x-icon.svg"
                    fillMode: Image.PreserveAspectFit
                    iconColor: cancelMouseArea.containsMouse ? "White" : "Black"
                    MouseArea {
                        id: cancelMouseArea
                        anchors.fill: parent

                        hoverEnabled: true
                        onClicked: {
                            selected = false
                            delegateRoot.ListView.view.cancel(index)
                        }
                    }
                }
                Text {
                    width: parent.width - 50
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight

                    font.pixelSize: 15
                    color: fontColor
                    text: model.text
                }
            }
        }
    }
    ScrollBar.vertical: ScrollBar {
        id: scrollBar
        width: 10

        policy: ScrollBar.AsNeeded
    }
}
