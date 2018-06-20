import QtQuick 2.9
import QtQuick.Controls 2.0

Item {
    id: root

    property alias pressed: switchRoot.pressed
    property alias down: switchRoot.down
    property alias checked: switchRoot.checked

    property real switchWidth: 52
    property real switchHeight: 26
    property color textColor: "black"
    property color handleColor: "white"
    property color grooveFillColor: "#0cf"
    property color grooveColor: "#ccc"
    property string label: ""
    property string checkedLabel: ""
    property string uncheckedLabel: ""
    property bool labelsInside: true
    property bool labelLeft: true
    property real fontSize: 10

    implicitHeight: childrenRect.height
    implicitWidth: childrenRect.width

    Text {
        id: labelText
        text: root.label
        width: contentWidth
        height: root.labelLeft ? switchRoot.height : contentHeight
        topPadding: root.label === "" ? 0 : root.labelLeft ? (switchRoot.height-contentHeight)/2 : 0
        bottomPadding: topPadding
    }

    Text {
        id: uncheckedLabelText
        visible: uncheckedLabel === "" ? false : !root.labelsInside
        text: uncheckedLabel
        font.pixelSize: root.fontSize
        anchors {
            left: root.labelLeft ? labelText.right : labelText.left
            leftMargin: root.label === "" ? 0 : root.labelLeft ? 10 : 0
            verticalCenter: switchRoot.verticalCenter
        }
        color: root.textColor
        width: root.labelsInside ? 0 : contentWidth
    }

    Text {
        id: checkedLabelText
        visible: uncheckedLabel === "" ? false : !root.labelsInside
        text: checkedLabel
        font.pixelSize: root.fontSize
        anchors {
            left: switchRoot.right
            verticalCenter: switchRoot.verticalCenter
            leftMargin: root.labelsInside ? 0 : 5
        }
        color: root.textColor
        width: root.labelsInside ? 0 : contentWidth
    }

    Switch {
        id: switchRoot

        anchors {
            left: uncheckedLabelText.right
            leftMargin: root.labelsInside ? 0 : 5
            top: root.labelLeft ? labelText.top : labelText.bottom
            topMargin: root.label === "" ? 0 : root.labelLeft ? 0 : 5
        }
        width: groove.width
        height: groove.height
        padding: 0

        indicator: Rectangle {
            id: groove
            width: root.switchWidth
            height: root.switchHeight
            y: parent.height / 2 - height / 2
            radius: 13
            color: root.grooveColor

            Text {
                id: uncheckedText
                visible: uncheckedLabel === "" ? false : root.labelsInside
                color: "white"
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: 5
                }
                font.pixelSize: root.fontSize
                text: root.uncheckedLabel
            }

            Rectangle {
                id: grooveFill
                visible: width === handle.width ? false : true
                width: ((switchRoot.visualPosition * parent.width) + (1-switchRoot.visualPosition) * handle.width)
                height: parent.height
                color: root.grooveFillColor
                radius: height/2

                Behavior on width {
                    enabled: switchRoot.pressed ? false : true
                    NumberAnimation { duration: 100 }
                }

                Text {
                    id: checkedText
                    visible: checkedLabel === "" ? false : root.labelsInside
                    color: "white"
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: 5
                    }
                    font.pixelSize: root.fontSize
                    text: root.checkedLabel
                }
            }

            Rectangle {
                id: handle
                x: ((switchRoot.visualPosition * parent.width) + (1-switchRoot.visualPosition) * width) - width
                width: 26
                height: 26
                radius: 13
                color: {
                    root.down ?
                        Qt.rgba(root.handleColor.r/1.1, root.handleColor.g/1.1, root.handleColor.b/1.1, 1) :
                        root.handleColor
                }
                border.color: {
                    root.checked ?
                        Qt.rgba(root.grooveFillColor.r/1.5, root.grooveFillColor.g/1.5, root.grooveFillColor.b/1.5, 1) :
                        Qt.rgba(root.grooveColor.r/1.5, root.grooveColor.g/1.5, root.grooveColor.b/1.5, 1)
                }

                Behavior on x {
                    enabled: switchRoot.pressed ? false : true
                    NumberAnimation { duration: 100 }
                }
            }
        }
    }
}
