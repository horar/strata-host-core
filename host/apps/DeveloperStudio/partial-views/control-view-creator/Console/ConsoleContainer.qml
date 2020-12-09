import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import QtQuick.Window 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.theme 1.0


Rectangle {
    id: root
    Layout.fillHeight: true
    Layout.fillWidth: true
    color: "#eee"
    z: 3

    property int warningCount: 0
    property int errorCount: 0

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


                    RowLayout {
                        Layout.preferredHeight: 30
                        spacing: 0

                        Item {
                            Layout.preferredWidth: 30
                            Layout.preferredHeight: 30

                            SGIcon {
                                anchors.centerIn: parent
                                source: "qrc:/sgimages/exclamation-triangle.svg"
                                iconColor: Theme.palette.warning
                                height: 20
                                width: height
                                enabled: warningCount > 0

                                Rectangle {
                                    anchors.centerIn: parent
                                    height: 13
                                    width: 4
                                    z: -1
                                    color: "white"
                                }
                            }
                        }

                        SGText {
                            text: warningCount
                            Layout.alignment: Qt.AlignVCenter
                            height: 30
                            color: "white"
                        }

                        Item {
                            Layout.preferredHeight: 30
                            Layout.preferredWidth: 30

                            SGIcon {
                                anchors.centerIn: parent
                                source: "qrc:/sgimages/exclamation-circle.svg"
                                iconColor: Theme.palette.error
                                height: 20
                                width: height
                                enabled: errorCount > 0

                                Rectangle {
                                    anchors.centerIn: parent
                                    height: 12
                                    width: 4
                                    z: -1
                                    color: "white"
                                }
                            }
                        }

                        SGText {
                            text: errorCount
                            Layout.alignment: Qt.AlignVCenter
                            color: "white"
                            height: 30
                        }
                    }



                Item {
                    Layout.preferredWidth: 10
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

                        onTextChanged: {
                            consoleLogger.searchText = text
                        }
                    }
                }

                Rectangle {
                    Layout.preferredHeight: 30
                    Layout.preferredWidth: 30

                    color: broomArea.containsMouse ? "#aaa" : "transparent"

                    SGIcon {
                        source: "qrc:/sgimages/broom.svg"
                        iconColor: "#ddd"
                        anchors.centerIn: parent
                        width: 20
                        height: width
                    }

                    MouseArea {
                        id: broomArea

                        anchors.fill: parent
                        hoverEnabled: true

                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            consoleLogger.clearLogs()
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                RowLayout{
                    Layout.alignment: Qt.AlignRight
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
                        rotation: consoleContainer.state !== "normal" && consoleContainer.state !== "minimize" ? 180 : 0
                    }

                    MouseArea {
                        id: closeArea
                        anchors.fill: closeButton
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true

                        onClicked: {
                            if(consoleContainer.state !== "normal" && consoleContainer.state !== "minimize"){
                                consoleContainer.height = 200
                                consoleContainer.state = "normal"
                            } else {
                                consoleContainer.state = "maximize"
                                consoleContainer.height = 750
                            }
                        }
                    }
                }

                Rectangle {
                    id: retractButton
                    height: 30
                    width: height
                    color: retractArea.containsMouse ? "#aaa" : "transparent"
                    Layout.alignment: Qt.AlignRight

                        SGIcon {
                            anchors.centerIn: retractButton
                            height: 20
                            width: height
                            source: "qrc:/sgimages/times.svg"
                            iconColor: "#ddd"
                        }

                        MouseArea {
                            id: retractArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                consoleContainer.height = topBar.height
                                consoleContainer.state = "minimize"
                            }
                        }
                    }
                }
            }
        }

        ConsoleLogger {
            id: consoleLogger
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

}
