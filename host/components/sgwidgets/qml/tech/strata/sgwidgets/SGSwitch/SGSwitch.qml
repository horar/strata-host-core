import QtQuick 2.12
import QtQuick.Controls 2.12

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

    property real fontSize: 10
    opacity: enabled ? 1 : 0.2

    // Optional Configurations:
    property alias switchWidth: groove.width
    property alias switchHeight: groove.height
    property color handleColor: "white"
    property alias grooveFillColor: grooveFill.color
    property color grooveColor: groove.color
    property color textColor: "black"
    property alias label: labelText.text
    property bool labelLeft: true
    property alias checkedLabel: checkedLabelText.text
    property alias uncheckedLabel: uncheckedLabelText.text
    property alias overrideLabelWidth: labelText.width
    property bool labelsInside: true

    implicitHeight: root.labelLeft ? switchRoot.height : labelText.height + switchRoot.height + switchRoot.anchors.topMargin
    implicitWidth: { root.labelLeft ?
                        root.labelsInside ?
                            labelText.width + switchRoot.width + uncheckedLabelText.anchors.leftMargin :
                            labelText.width + switchRoot.width + uncheckedLabelText.width + checkedLabelText.width +
                                uncheckedLabelText.anchors.leftMargin + checkedLabelText.anchors.leftMargin + switchRoot.anchors.leftMargin :
                         root.labelsInside ?
                            switchRoot.width :
                            Math.max(labelText.width, switchRoot.width + uncheckedLabelText.width + checkedLabelText.width +
                                uncheckedLabelText.anchors.leftMargin + checkedLabelText.anchors.leftMargin + switchRoot.anchors.leftMargin)
    }

    Text {
        id: labelText
        text: ""
        width: contentWidth
        height: text === "" ? 0 : root.labelLeft ? switchRoot.height : contentHeight
        topPadding: text === "" ? 0 : root.labelLeft ? (switchRoot.height-contentHeight)/2 : 0
        bottomPadding: topPadding
        color: root.textColor
    }

    Text {
        id: uncheckedLabelText
        visible: text === "" ? false : !root.labelsInside
        text: ""
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
        visible: text === "" ? false : !root.labelsInside
        text: ""
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
            leftMargin: root.labelsInside ? 0 : 5
            top: root.labelLeft ? labelText.top : labelText.bottom
            topMargin: root.label === "" ? 0 : root.labelLeft ? 0 : 5
        }
        width: groove.width
        height: groove.height
        padding: 0

        indicator: Rectangle {
            id: groove
            width: 52
            height: 26
            y: parent.height / 2 - height / 2
            radius: 13
            color: "#ccc"

            Text {
                id: uncheckedText
                visible: uncheckedLabel === "" ? false : root.labelsInside
                color: "white"
                anchors {
                    verticalCenter: groove.verticalCenter
                    right: groove.right
                    rightMargin: 5
                }
                font.pixelSize: root.fontSize
                text: root.uncheckedLabel
            }

            Rectangle {
                id: grooveFill
                visible: width === handle.width ? false : true
                width: ((switchRoot.visualPosition * groove.width) + (1-switchRoot.visualPosition) * handle.width)
                height: groove.height
                color: "#0cf"
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
                        verticalCenter: grooveFill.verticalCenter
                        left: grooveFill.left
                        leftMargin: 5
                    }
                    font.pixelSize: root.fontSize
                    text: root.checkedLabel
                }
            }

            Rectangle {
                id: handle
                x: ((switchRoot.visualPosition * groove.width) + (1-switchRoot.visualPosition) * width) - width
                width: groove.height
                height: width
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
