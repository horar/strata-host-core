import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import QtQuick.Window 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.theme 1.0

import "../components"

Rectangle {
    id: root
    visible: !startContainer.visible

    Layout.minimumHeight: 30
    implicitHeight: 200
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
                            height: 25
                            width: height
                            enabled: warningCount > 0

                            Rectangle {
                                anchors.centerIn: parent
                                height: 16
                                width: 5
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
                        fontSizeMultiplier: 1.2
                    }

                    Item {
                        Layout.preferredHeight: 30
                        Layout.preferredWidth: 30

                        SGIcon {
                            anchors.centerIn: parent
                            source: "qrc:/sgimages/exclamation-circle.svg"
                            iconColor: Theme.palette.error
                            height: 25
                            width: height
                            enabled: errorCount > 0

                            Rectangle {
                                anchors.centerIn: parent
                                height: 16
                                width: 5
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
                        fontSizeMultiplier: 1.2
                    }
                }

                Item {
                    Layout.preferredWidth: 10
                }

                SGControlSearchComboBox {
                    id: searchBox
                    Layout.preferredHeight: 30
                    Layout.preferredWidth: 330

                    onTextChanged: {
                        consoleLogger.searchText = text
                    }
                }

                SGControlViewIconButton {
                    Layout.preferredHeight: 30
                    Layout.preferredWidth: 30
                    source: "qrc:/sgimages/plus.svg"

                    onClicked: {
                        consoleLogger.fontMultiplier += 0.1
                    }
                }

                SGControlViewIconButton {
                    Layout.preferredHeight: 30
                    Layout.preferredWidth: 30
                    source: "qrc:/sgimages/minus.svg"

                    onClicked: {
                        consoleLogger.fontMultiplier -= 0.1
                    }
                }

                SGControlViewIconButton {
                    Layout.preferredHeight: 30
                    Layout.preferredWidth: 30
                    source: "qrc:/sgimages/broom.svg"

                    onClicked:  {
                        consoleLogger.clearLogs()
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                RowLayout{
                    Layout.alignment: Qt.AlignRight

                    SGControlViewIconButton {
                        Layout.preferredHeight: 30
                        Layout.preferredWidth: 30
                        source: "qrc:/sgimages/times.svg"
                        Layout.alignment: Qt.AlignRight

                        onClicked:  {
                            consoleContainer.visible = false
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

