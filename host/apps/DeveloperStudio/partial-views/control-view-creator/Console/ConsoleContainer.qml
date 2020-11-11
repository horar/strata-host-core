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


    Rectangle {
        id: topBar
        width: root.width
        height: 30
        color: "#444"
        z: 5

        RowLayout {
            anchors.fill: parent

            SGText {
                text: "Console Output"
                alternativeColorEnabled: true
                fontSizeMultiplier: 1.15
                leftPadding: 5
            }

                ComboBox {
                    id: comboBox
                    Layout.preferredHeight: 30
                    Layout.preferredWidth: 30
                    model: [{"source":"qrc:/sgimages/zoom.svg", "text": "search", "index": 0},{"source":"qrc:/sgimages/tools.svg", "text": "tools", "index": 1 },{"source":"qrc:/sgimages/clock.svg", "text": "breakpoints", "index": 2}]
                    currentIndex: 0
                    background: Rectangle {
                        color: "#444"
                        anchors.fill: parent
                    }

                    contentItem: Item {
                        anchors.fill: parent
                        SGIcon {
                            source: comboBox.model[comboBox.currentIndex].source
                            height: 20
                            width: 20
                            anchors.centerIn: parent
                            iconColor: "#ddd"
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
                                comboBox.popup.close()
                            }
                        }
                    }
            }

            Rectangle {
                id: searchFilter
                Layout.fillHeight: true
                Layout.preferredWidth: 300
                border.color: "#444"
                border.width: 0.5
                TextInput {
                    text: "Search here..."
                    font.family: "Helvetica"
                    font.pixelSize: 14
                    anchors {
                        verticalCenter: searchFilter.verticalCenter
                        left: searchFilter.left
                        right: searchFilter.right
                    }

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
}
