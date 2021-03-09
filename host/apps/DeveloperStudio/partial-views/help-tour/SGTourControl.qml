import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import "qrc:/js/help_layout_manager.js" as Help

import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0

ColumnLayout {
    id: root
    width: 360
    focus: true
    property int index: 0
    property alias description: description.text
    property real fontSizeMultiplier: 1
    spacing: 0

    signal close()
    onClose: Help.closeTour()

    RowLayout{
        Layout.fillWidth: true
        spacing: 0
        Item {
            Layout.fillWidth: true
        }

        SGIcon {
            id: closer
            source: "qrc:/sgimages/times.svg"
            iconColor: closerMouse.containsMouse ? "lightgrey" : "grey"
            Layout.preferredHeight: 18
            Layout.preferredWidth: Layout.preferredHeight

            MouseArea {
                id: closerMouse
                anchors {
                    fill: closer
                }
                onClicked: root.close()
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
            }
        }

        Item {
            Layout.preferredWidth: 10
        }
    }

    ColumnLayout {
        id: column
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        spacing: 15

        SGText {
            id: helpText
            color:"grey"
            fontSizeMultiplier: 1.25 //* root.fontSizeMultiplier
            text: " "
            Layout.alignment: Qt.AlignHCenter
            onVisibleChanged: {
                if (visible) {
                    text = (root.index + 1) + "/" + Help.tour_count
                }
            }
        }

        Rectangle {
            Layout.fillWidth: false
            Layout.preferredWidth: root.width - 40
            Layout.preferredHeight: 1
            color: "darkgrey"
            Layout.alignment: Qt.AlignHCenter
        }

        SGTextEdit {
            id: description
            text: "Placeholder Text"
            color: "grey"
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignHCenter

            readOnly: true
            wrapMode: TextEdit.Wrap
            fontSizeMultiplier: root.fontSizeMultiplier
        }

        RowLayout {
            id: row
            Layout.fillWidth: true
            Layout.minimumHeight: prevButton.height
            Layout.maximumHeight: prevButton.height
            Layout.fillHeight: false
            Layout.alignment: Qt.AlignHCenter
            spacing: 15

            Button {
                id: prevButton
                text: "Prev"
                Layout.alignment: Qt.AlignLeft
                onClicked: {
                    Help.prev(root.index)
                }
                enabled: root.index !== 0

                property bool showToolTip: false

                onHoveredChanged: {
                    if (prevButton.enabled){
                        if (hovered) {
                            prevButtonTimer.start()
                        } else {
                            prevButton.showToolTip = false; prevButtonTimer.stop();
                        }
                    }
                }

                Timer {
                    id: prevButtonTimer
                    interval: 500
                    onTriggered: prevButton.showToolTip = true;
                }

                ToolTip {
                    text: "Hotkey: ←"
                    visible: prevButton.showToolTip
                    z: 67
                }

                MouseArea {
                    id: buttonCursor
                    anchors.fill: parent
                    onPressed:  mouse.accepted = false
                    cursorShape: Qt.PointingHandCursor
                }
            }

            Button {
                id: nextButton
                text: "Next"
                Layout.alignment: Qt.AlignRight
                property bool showToolTip: false

                onVisibleChanged: {
                    if (visible) {
                        text = (root.index + 1) === Help.tour_count ? "End Tour" : "Next"
                    }
                }

                onClicked: {
                    Help.next(root.index)
                }

                onHoveredChanged: {
                    if (hovered) {
                        nextButtonTimer.start()
                    } else {
                        nextButton.showToolTip = false; nextButtonTimer.stop();
                    }
                }

                Timer {
                    id: nextButtonTimer
                    interval: 500
                    onTriggered: nextButton.showToolTip = true;
                }

                ToolTip {
                    text: "Hotkey: →"
                    visible: nextButton.showToolTip
                    z: 67
                }

                MouseArea {
                    id: buttonCursor1
                    anchors.fill: parent
                    onPressed:  mouse.accepted = false
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }
    }
}
