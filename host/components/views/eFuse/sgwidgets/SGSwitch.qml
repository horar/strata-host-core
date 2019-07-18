import QtQuick 2.9
import QtQuick.Controls 2.0

Item {
    id: root
    signal released()
    signal canceled()
    signal clicked()
    signal toggled()
    signal press()
    signal pressAndHold()
    property alias pressed: switchRoot.pressed
    property alias down: switchRoot.down
    property alias checked: switchRoot.checked
    property real switchHeight: 30
    property real fontSize: 15
    // Optional Configurations:
    property real switchWidth: 65
    property color handleColor: "white"
    property color grooveFillColor: "#0cf"
    property color grooveColor: "#ccc"
    property color textColor: "black"
    property string label: ""
    property bool labelLeft: true
    property string checkedLabel: ""
    property string uncheckedLabel: ""
    property bool labelsInside: true
    property int fontSizeLabel: 10

    implicitHeight: root.labelLeft ? switchRoot.height : labelText.height + switchRoot.height + switchRoot.anchors.topMargin
    implicitWidth: { root.labelLeft ?
                        root.labelsInside ?
                            labelText.width + switchRoot.width + uncheckedLabelText.anchors.leftMargin + switchRoot.anchors.leftMargin :
                            labelText.width + switchRoot.width + uncheckedLabelText.width + checkedLabelText.width +
                                uncheckedLabelText.anchors.leftMargin + checkedLabelText.anchors.leftMargin + switchRoot.anchors.leftMargin :
                         root.labelsInside ?
                            switchRoot.width :
                            Math.max(labelText.width, switchRoot.width + uncheckedLabelText.width + checkedLabelText.width +
                                uncheckedLabelText.anchors.leftMargin + checkedLabelText.anchors.leftMargin + switchRoot.anchors.leftMargin)
    }

    Text {
        id: labelText
        text: root.label
        width: contentWidth
        height: root.label === "" ? 0 : root.labelLeft ? switchRoot.height : contentHeight
        topPadding: root.label === "" ? 0 : root.labelLeft ? (switchRoot.height-contentHeight)/2 : 0
        bottomPadding: topPadding
        color: root.textColor
        font.bold: true
        font.pixelSize: fontSizeLabel
        horizontalAlignment: Text.AlignHCenter
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
        onReleased: root.released()
        onCanceled: root.canceled()
        onClicked: root.clicked()
        onToggled: root.toggled()
        onPressed: root.press()
        onPressAndHold: root.pressAndHold()

        anchors {
            left: uncheckedLabelText.right
            leftMargin: 10
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
                clip:true

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
                width: root.switchHeight
                height: root.switchHeight
                radius: 13
                color: root.down ? colorMod(root.handleColor, 1.1) : root.handleColor
                border.color: root.checked ? colorMod(root.grooveFillColor, 1.5) : colorMod(root.grooveColor, 1.5)

                Behavior on x {
                    enabled: switchRoot.pressed ? false : true
                    NumberAnimation { duration: 100 }
                }
            }
        }
    }

    // Lighten or darken a color based on a factor
    function colorMod (color, factor) {
        return Qt.rgba(color.r/factor, color.g/factor, color.b/factor, 1 )
    }
}

