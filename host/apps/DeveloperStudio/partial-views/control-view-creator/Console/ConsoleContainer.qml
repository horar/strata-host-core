import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0


Rectangle {
    id: root
    Layout.fillWidth: true
    Layout.preferredHeight: 300
    Layout.maximumHeight: 500
    color: "#eee"
    z: 3

ColumnLayout {
    anchors.fill: parent
    spacing: 0
    z: 5
    Rectangle {
        id: topBar
        Layout.fillWidth: true
        Layout.preferredHeight: 30
        color: "#444"

        RowLayout {
            anchors.fill: parent
            spacing: 0

            SGText {
                text: "Console Output"
                alternativeColorEnabled: true
                fontSizeMultiplier: 1.15
                leftPadding: 5
            }

                ComboBox {
                    id: comboBox
                    Layout.preferredHeight: 30
                    Layout.preferredWidth: 150
                    model: [{"source":"qrc:/sgimages/zoom.svg", "text": "console", "index": 0},{"source":"qrc:/sgimages/tools.svg", "text": "tools", "index": 1 },{"source":"qrc:/sgimages/clock.svg", "text": "breakpoints", "index": 2}, {"source":"qrc:/sgimages/coding.svg", "text":"debugging", "index": 3}]
                    currentIndex: 0
                    background: Rectangle {
                        color: "#444"
                        anchors.fill: parent
                    }

                    contentItem: Item {
                        anchors.fill: parent
                        SGIcon {
                            id: contentIcon
                            source: comboBox.model[comboBox.currentIndex].source
                            height: 20
                            width: 20
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 5
                            iconColor: "#ddd"
                        }

                        SGText {
                            text: comboBox.model[comboBox.currentIndex].text
                            color: "#ddd"
                            fontSizeMultiplier: 1.05
                            leftPadding: 10
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: contentIcon.right
                        }
                    }

                    delegate: Rectangle {
                        id: iconButton
                        height: 30
                        width: 150
                        color: iconArea.containsMouse ? "#aaa" : "transparent"
                        SGIcon {
                            id: icon
                            height: 20
                            width: height
                            source: modelData.source
                            iconColor: "#777"
                            anchors.verticalCenter: iconButton.verticalCenter
                            anchors.left: iconButton.left
                            anchors.leftMargin: 5

                        }

                        SGText {
                            text: modelData.text
                            anchors.verticalCenter: iconButton.verticalCenter
                            anchors.left: icon.right
                            leftPadding: 10
                            fontSizeMultiplier: 1.05
                        }


                        MouseArea {
                            id: iconArea
                            anchors.fill: iconButton
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true

                            onClicked: {
                                comboBox.currentIndex = modelData.index
                                loader.state = comboBox.model[modelData.index].text
                                comboBox.popup.close()
                            }
                        }
                    }
            }

            Rectangle {
                id: searchFilter
                Layout.preferredHeight: 30
                Layout.preferredWidth: 300
                border.color: "#444"
                border.width: 0.5
                TextField {
                    font.family: "Merryweather"
                    font.pixelSize: 14
                    anchors.fill: parent

                    leftPadding: 5
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            Rectangle {
                id: chevronButton
                height: 30
                width: 30
                color: chevronArea.containsMouse ? "#aaa" : "transparent"
                SGIcon {
                    anchors.centerIn: chevronButton
                    height: 20
                    width: height
                    source: "qrc:/sgimages/chevron-down.svg"
                    iconColor: "#ddd"
                    rotation: root.state === "minimize" ? 180 : 0
                }

                MouseArea {
                    id: chevronArea
                    anchors.fill: chevronButton
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        if(root.state === "original") {
                            root.state = "minimize"
                        } else {
                            root.state = "original"
                        }
                    }
                }
            }

            Rectangle{
                id: closeButton
                height: 30
                width: height
                color: closeArea.containsMouse ? "#aaa" : "transparent"
                Layout.alignment: Qt.AlignRight
                SGIcon {
                    anchors.centerIn: closeButton
                    height: 20
                    width: height
                    source: "qrc:/sgimages/times.svg"
                    iconColor: "#ddd"
                }
                MouseArea {
                    id: closeArea
                    anchors.fill: closeButton
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    onClicked: {
                        root.visible = false
                    }
                }
            }
        }
    }

    state: "original"
    states: [
        State {
            name: "minimize"
            PropertyChanges {
                target: root
                Layout.preferredHeight: topBar.height
                Layout.fillWidth: true
            }
        },
        State {
            name: "original"
            PropertyChanges {
                target: root
                Layout.preferredHeight: 300
                Layout.fillWidth: true
            }
        }

    ]

    DragHandler {
        id: dragHandler
        target: root
        xAxis.enabled: false
        yAxis.enabled: root.state === "original"
        yAxis.minimum: 0
        yAxis.maximum: 100
    }

    Loader {
        id: loader
        Layout.fillHeight: true
        Layout.fillWidth: true

        state: "console"
        active: true
        source: "ConsoleLogger.qml"

        states: [
            State {
                name: "console"
                PropertyChanges {
                    target: loader
                    source: "ConsoleLogger.qml"
                }
            },
            State {
                name: "tools"
                PropertyChanges {
                    target: loader
                    source: "ConsoleTools.qml"
                }
            },
            State {
                name: "breakpoints"
                PropertyChanges {
                    target: loader
                    source: "ConsoleBreakpoints.qml"
                }
            },
            State {
                name: "debugging"
                PropertyChanges {
                    target: loader
                    source: "ConsoleDebugger.qml"
                }
            }



        ]
    }
   }
}
