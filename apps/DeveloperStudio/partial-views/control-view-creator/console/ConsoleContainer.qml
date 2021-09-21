/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import QtQuick.Window 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.theme 1.0

import "../components"

Rectangle {
    id: root
    anchors.fill: parent
    color: "#eee"

    signal clicked()
    property bool filterTypeWarning: false
    property bool filterTypeError: false

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: topBar
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            color: "#444"

            RowLayout {
                anchors.fill: parent
                spacing: 10

                SGText {
                    text: "Console Output"
                    alternativeColorEnabled: true
                    fontSizeMultiplier: 1.15
                    leftPadding: 5
                }

                RowLayout {
                    Layout.preferredHeight: 30
                    spacing: 5

                    Rectangle {
                        Layout.preferredWidth: 45
                        Layout.preferredHeight: 30
                        color: filterTypeWarning || warningMouseArea.containsMouse ? "#888" : "transparent"

                        Rectangle {
                            anchors.centerIn: warningIcon
                            height: 16
                            width: 5
                            color: "white"
                        }

                        SGIcon {
                            id: warningIcon
                            anchors {
                                verticalCenter: parent.verticalCenter
                                left: parent.left
                                leftMargin: 5
                            }
                            source: "qrc:/sgimages/exclamation-triangle.svg"
                            iconColor: Theme.palette.warning
                            height: 25
                            width: height
                            enabled: consoleLogWarningCount > 0
                        }

                        SGText {
                            text: consoleLogWarningCount
                            anchors.left: warningIcon.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 2
                            color: "white"
                            fontSizeMultiplier: 1.2
                        }

                        MouseArea{
                            id: warningMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                filterTypeWarning = !filterTypeWarning
                                consoleLogger.validateSearchText()
                            }
                        }
                    }

                    Rectangle {
                        Layout.preferredHeight: 30
                        Layout.preferredWidth: 45
                        color: filterTypeError || errorMouseArea.containsMouse ? "#888" : "transparent"

                        Rectangle {
                            anchors.centerIn: errorIcon
                            height: 16
                            width: 5
                            color: "white"
                        }

                        SGIcon {
                            id: errorIcon
                            anchors {
                                verticalCenter: parent.verticalCenter
                                left: parent.left
                                leftMargin: 5
                            }
                            source: "qrc:/sgimages/exclamation-circle.svg"
                            iconColor: Theme.palette.error
                            height: 25
                            width: height
                            enabled: consoleLogErrorCount > 0
                        }

                        SGText {
                            text: consoleLogErrorCount
                            anchors.left: errorIcon.right
                            anchors.leftMargin: 2
                            anchors.verticalCenter: parent.verticalCenter
                            color: "white"
                            fontSizeMultiplier: 1.2
                        }

                        MouseArea{
                            id: errorMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                filterTypeError = !filterTypeError
                                consoleLogger.validateSearchText()
                            }
                        }
                    }
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
                        id: openWindow
                        Layout.preferredHeight: 30
                        Layout.preferredWidth: 30
                        source: popupWindow ? "qrc:/sgimages/sign-out.svg" : "qrc:/sgimages/sign-in.svg"

                        onClicked:  {
                            popupWindow = !popupWindow
                        }
                    }

                    SGControlViewIconButton {
                        Layout.preferredHeight: 30
                        Layout.preferredWidth: 30
                        source: "qrc:/sgimages/times.svg"
                        Layout.alignment: Qt.AlignRight

                        onClicked:  {
                            if (popupWindow) {
                                popupWindow = false
                            }
                            root.clicked()
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

