import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

GridLayout {
    id: root
    rowSpacing: 0
    columnSpacing: 0
    Layout.fillWidth: false
    Layout.fillHeight: false
    clip: true

    property real fontSizeMultiplier: 1.0
    property color textColor: "black"
    property alias mirror: slider.mirror
    property alias handleSize: slider.handleSize
    property alias orientation: slider.orientation
    property alias value: slider.correctedValue
    property alias from: slider.from
    property alias to: slider.to
    property alias horizontal: slider.horizontal
    property alias vertical: slider.vertical
    property alias showTickmarks: tickmarkRow.visible
    property alias showLabels: numsContainer.visible
    property alias showInputBox: inputBox.visible
    property alias showToolTip: slider.showToolTip
    property alias stepSize: slider.stepSize
    property alias live: slider.live
    property alias visualPosition: slider.visualPosition
    property alias position: slider.position
    property alias snapMode: slider.snapMode
    property alias pressed: slider.pressed
    property alias grooveColor: slider.grooveColor
    property alias fillColor: slider.fillColor

    property alias slider: slider
    property alias inputBox: inputBox
    property alias fromText: fromText
    property alias toText: toText
    property alias tickmarkRepeater: tickmarkRepeater

    signal userSet(real value)
    signal moved()

    function userSetValue (value) {  // sets value, signals userSet
        slider.userSetValue(value)
    }

    function increase () {
        slider.increase()
    }

    function decrease () {
        slider.decrease()
    }

    function valueAt (position) {
        return slider.valueAt(position)
    }

    Slider {
        id: slider
        padding: 0
        Layout.fillHeight: slider.handleSize > -1 && root.horizontal ? false : true
        Layout.fillWidth: slider.handleSize > -1 && !root.horizontal ? false : true
        Layout.column: root.horizontal ? 0 : root.mirror ? 1 : 0
        Layout.row: root.horizontal ? root.mirror ? 1 : 0 : 0
        Layout.alignment: Qt.AlignHCenter
        implicitWidth: root.horizontal ? 20 : slider.handleSize > -1 ? slider.handleSize : 20
        implicitHeight: root.horizontal ? slider.handleSize > -1 ? slider.handleSize : 20 : 20
        stepSize: .1

        property int tickmarkCount: stepSize === 0.0 ? 2 : ((to - from) + stepSize) / stepSize
        property real grooveHandleRatio: .2
        property color grooveColor: "#bbb"
        property color fillColor: "#21be2b"
        property bool mirror: false
        property bool showToolTip: true
        property real handleSize: -1

        // when using stepSize <1, value is generated with rounding error: https://bugreports.qt.io/browse/QTBUG-59020
        // this also allows us to filter for user changes to value
        property real correctedValue: (from + to)/2

        property int decimals: {
            if (stepSize === 0.0) {
                // stepSize of 0 logically means infinite decimals; 15 is max of double precision IEEE 754
                return 15
            } else if (Math.floor(slider.stepSize) === slider.stepSize) {
                return 0
            } else {
                return slider.stepSize.toString().split(".")[1].length || 0
            }
        }

        onCorrectedValueChanged: {
            value = correctedValue
        }

        onValueChanged: {
            // stops correctedValue changes from looping back to it (eg. when correctedValue is directly set to an invalid number)
            var fixedValue = parseFloat(value.toFixed(decimals))
            if (fixedValue !== correctedValue && value !== correctedValue) {
                userSetValue(value)
            }
        }

        onMoved: root.moved()

        function userSetValue(value) {
            var fixedValue = parseFloat(value.toFixed(decimals))
            if (fixedValue !== correctedValue) {
                root.userSet(fixedValue)
                correctedValue = fixedValue
            }
        }

        background: Rectangle {
            id: groove

            property real grooveHandleRatio: slider.grooveHandleRatio < 0 ? 0 : slider.grooveHandleRatio > 1 ? 1 : slider.grooveHandleRatio
            x: slider.horizontal ? 0 : slider.width / 2 - width / 2
            y: slider.horizontal ? slider.height / 2 - height / 2 : 0
            implicitWidth: slider.horizontal ? handle.width : handle.width * grooveHandleRatio
            implicitHeight: slider.horizontal ? handle.height * grooveHandleRatio : handle.height
            width: slider.horizontal ? slider.width : implicitWidth
            height: slider.horizontal ? implicitHeight : slider.height
            radius: (Math.min(height, width))/ 2
            color: slider.grooveColor

            Rectangle {
                id: grooveFill
                width: slider.horizontal ? handle.x + handle.width / 2: groove.width
                height: slider.horizontal ? groove.height : groove.height - handle.y - handle.height / 2
                anchors {
                    bottom: groove.bottom
                }
                color: slider.fillColor
                radius: groove.radius
            }

            Grid {
                id: tickmarkRow
                visible: false
                z: -1
                x: {
                    if (slider.horizontal) {
                        return (handle.width / 2) - 1
                    } else {
                        if (mirror) {
                            return (groove.width / 2) - tickmarkRepeater.tickmarkWidth
                        } else {
                            return groove.width / 2
                        }
                    }
                }
                y: {
                    if (slider.horizontal) {
                        if (mirror) {
                            return (groove.height / 2) - tickmarkRepeater.tickmarkHeight
                        } else {
                            return groove.height / 2
                        }
                    } else {
                        return (handle.height / 2) - 1
                    }
                }
                columns: slider.horizontal ? slider.tickmarkCount : 1
                spacing: {
                    if (slider.horizontal) {
                        return slider.width / (slider.tickmarkCount - 1) - tickmarkRepeater.tickmarkWidth - (handle.width / (slider.tickmarkCount-1))
                    } else {
                        return slider.height / (slider.tickmarkCount - 1) - tickmarkRepeater.tickmarkHeight - (handle.width / (slider.tickmarkCount-1))
                    }
                }

                Repeater {
                    id: tickmarkRepeater
                    model: slider.tickmarkCount < 100 ? slider.tickmarkCount : 2 // don't flood with tickmarks if (to-from) is large and stepSize is very small
                    property real tickmarkHeight: slider.horizontal ? slider.height / 2 : 1
                    property real tickmarkWidth: slider.horizontal ? 1 : slider.width / 2
                    delegate: Rectangle {
                        id: tickmark
                        color: groove.color
                        width: tickmarkRepeater.tickmarkWidth
                        height: tickmarkRepeater.tickmarkHeight
                    }
                }
            }
        }

        handle: Rectangle {
            id: handle
            x: slider.horizontal ? slider.visualPosition * (slider.width - width) : slider.width / 2 - width /2
            y: slider.horizontal ? slider.height / 2 - height / 2 : slider.visualPosition * (slider.height - height)
            implicitWidth: height
            implicitHeight: Math.min(slider.height, slider.width)
            radius: (Math.min(height, width))/ 2
            color: slider.pressed ? "#f0f0f0" : "#f6f6f6"
            border.color: groove.color

            ToolTip {
                id: toolTip
                visible: slider.showToolTip && slider.pressed
                text: (slider.valueAt(slider.position)).toFixed(slider.decimals) // not 'correctedValue' so it shows live value when 'live: false'

                contentItem: SGText {
                    color: root.textColor
                    text: toolTip.text
                    font.family: Fonts.inconsolata
                    fontSizeMultiplier: root.fontSizeMultiplier
                }

                background: Rectangle {
                    id: toolTipBackground
                    color: "#eee"
                    radius: 2
                }
            }
        }
    }

    Item {
        id: numsContainer
        Layout.preferredHeight: root.horizontal ? numsGrid.implicitHeight : fromText.contentHeight + toText.contentHeight
        Layout.preferredWidth: root.horizontal ? fromText.contentWidth + toText.contentWidth : numsGrid.implicitWidth
        Layout.fillHeight: true
        Layout.fillWidth: true
        Layout.maximumHeight: root.horizontal ? Layout.preferredHeight : slider.height
        Layout.maximumWidth: root.horizontal ? slider.width : Layout.preferredWidth
        Layout.column: root.horizontal ? 0 : root.mirror ? 0 : 1
        Layout.row: root.horizontal ? root.mirror ? 0 : 1 : 0
        Layout.rightMargin: !root.horizontal && root.mirror ? 3 * fontSizeMultiplier : 0  // for padding against tickmark when vertical
        Layout.leftMargin: !root.horizontal && !root.mirror ? 3 * fontSizeMultiplier : 0

        GridLayout {
            id: numsGrid
            anchors.fill: numsContainer
            rowSpacing: 0
            columnSpacing: 0

            SGText {
                id: fromText
                text: slider.from
                fontSizeMultiplier: root.fontSizeMultiplier
                Layout.alignment: root.horizontal ? Qt.AlignLeft : Qt.AlignBottom
                Layout.column: 0
                Layout.row: root.horizontal ? 0 : 1
                Layout.bottomMargin: root.horizontal ? 0 : (contentHeight < slider.handle.height) ? (slider.handle.height - contentHeight) / 2 : 0
                Layout.leftMargin: root.horizontal ? (contentWidth < slider.handle.width) ? (slider.handle.width - contentWidth) / 2 : 0 : 0
                Layout.fillWidth: true
                elide: Text.ElideLeft
                horizontalAlignment: !root.horizontal && root.mirror ? Text.AlignRight : Text.AlignLeft
                color: root.textColor
            }

            SGText {
                id: toText
                text: slider.to
                fontSizeMultiplier: root.fontSizeMultiplier
                Layout.alignment: root.horizontal ? Qt.AlignRight : Qt.AlignTop
                Layout.column: root.horizontal ? 1 : 0
                Layout.row: 0
                Layout.topMargin: root.horizontal ? 0 : (contentHeight < slider.handle.height) ? (slider.handle.height - contentHeight) / 2 : 0
                Layout.rightMargin: root.horizontal ? (contentWidth < slider.handle.width) ? (slider.handle.width - contentWidth) / 2 : 0 : 0
                Layout.fillWidth: true
                elide: Text.ElideLeft
                horizontalAlignment: root.horizontal || !root.horizontal && root.mirror ? Text.AlignRight : Text.AlignLeft
                color: root.textColor
            }
        }
    }

    SGInfoBox {
        id: inputBox
        Layout.column: root.horizontal ? 1 : root.mirror ? 1 : 0
        Layout.rowSpan: 1
        Layout.columnSpan: 1
        Layout.row: root.horizontal ? root.mirror ? 1 : 0 : 1
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: root.horizontal ? 0 : 5
        Layout.leftMargin: root.horizontal ? 5 : 1
        Layout.rightMargin: 1 // prevents root from clipping right border occasionally
        Layout.preferredWidth: implicitWidthHelper.width + boxFont.pixelSize
        Layout.maximumWidth: Layout.preferredWidth
        Layout.fillWidth: true
        fontSizeMultiplier: root.fontSizeMultiplier
        readOnly: false
        text: slider.correctedValue
        textColor: root.textColor

        validator: DoubleValidator {
            decimals: slider.decimals
        }

        onEditingFinished: slider.userSetValue(parseFloat(text))

        TextMetrics {
            id: implicitWidthHelper
            font: inputBox.boxFont
            text: {
                var string = "0"
                return string.repeat(lengthOfLongestString)
            }
            property int lengthOfLongestString: Math.max(root.from.toString().length, root.to.toString().length) + slider.decimals + (slider.decimals > 0 ? 1 : 0) // if decimal places, add 1 for decimal point
        }
    }
}
