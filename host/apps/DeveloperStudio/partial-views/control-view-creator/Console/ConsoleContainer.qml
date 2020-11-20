import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import QtQuick.Window 2.12

import tech.strata.sgwidgets 1.0


Rectangle {
    id: root
    Layout.fillHeight: true
    Layout.fillWidth: true
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
                spacing: 5

                SGText {
                    text: "Console Output"
                    alternativeColorEnabled: true
                    fontSizeMultiplier: 1.15
                    leftPadding: 5
                }

                Item {
                    Layout.preferredWidth: 30
                }

                SGIcon {
                    id: contentIcon
                    source: "qrc:/sgimages/zoom.svg"
                    Layout.preferredHeight: 20
                    Layout.preferredWidth: 20
                    Layout.alignment: Qt.AlignVCenter
                    iconColor: "#ddd"
                }

                Rectangle {
                    id: searchFilter
                    Layout.preferredHeight: 30
                    Layout.preferredWidth: 300
                    border.color: "#444"
                    border.width: 0.5

                    TextField {
                        font.pixelSize: 14
                        anchors.fill: parent
                        placeholderText: "search here..."
                        leftPadding: 5
                    }
                }

                RowLayout {
                    Layout.preferredWidth: 50
                    Layout.fillHeight: true
                    spacing: 0

                    Rectangle{
                        Layout.fillHeight: true
                        Layout.preferredWidth: 25
                        color: plusArea.containsMouse ? "#aaa" : "transparent"

                        SGIcon {
                            width: 15
                            height: width
                            anchors.centerIn: parent
                            source: "qrc:/sgimages/plus.svg"
                            iconColor: "#ddd"
                        }

                        MouseArea {
                            id: plusArea
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true

                            onClicked: {
                                // increase font size of the console logger
                                consoleLogger.fontMultiplier += 0.1
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 25
                        color: minusArea.containsMouse ? "#aaa" : "transparent"

                        SGIcon {
                            width: 15
                            height: width
                            anchors.centerIn: parent
                            source: "qrc:/sgimages/minus.svg"
                            iconColor: "#ddd"
                        }

                        MouseArea {
                            id: minusArea
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true

                            onClicked: {
                                // decrease font size of the console logger
                                consoleLogger.fontMultiplier -= 0.1
                            }
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
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
                        source: "qrc:/sgimages/chevron-up.svg"
                        iconColor: "#ddd"
                        rotation: consoleContainer.state !== "normal" || !(consoleContainer.height < 350) ? 180 : 0
                    }

                    MouseArea {
                        id: closeArea
                        anchors.fill: closeButton
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true

                        onClicked: {
                            if(consoleContainer.state === "drag"){
                                if(consoleContainer.height > 350){
                                    consoleContainer.state = "normal"
                                } else {
                                    consoleContainer.state = "max"
                                }
                            } else if(consoleContainer.state === "max") {
                                consoleContainer.state = "normal"
                            } else {
                                consoleContainer.state = "max"
                            }
                        }
                    }
                }
            }

            DragHandler {
                id: dragHandler
                target:root
                xAxis.enabled: false
                yAxis.minimum: Screen.desktopAvailableHeight - consoleContainer.height
                yAxis.maximum: Screen.desktopAvailableHeight - 150
            }

        }

        ConsoleLogger {
            id: consoleLogger
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }
}
