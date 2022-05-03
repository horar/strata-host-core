/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.7
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "qrc:/partial-views/login/"
import "qrc:/partial-views/"
import "qrc:/js/utilities.js" as Utility

import tech.strata.fonts 1.0
import tech.strata.logger 1.0
import tech.strata.sgwidgets 1.0
import tech.strata.signals 1.0
import tech.strata.theme 1.0

Item {
    id: root
    clip: true
    anchors.fill: parent

    Image {
        id: backgroundImage
        anchors.fill: parent
        source: "qrc:/images/grey-white-fade-background.svg"
    }

    ColumnLayout {
        anchors.fill: root
        spacing: 0

        RowLayout {
            Item {
                id: onSemiHeader
                Layout.fillWidth: true
                Layout.maximumHeight: 130
                Layout.preferredHeight: 130
                Layout.fillHeight: true

                Image {
                    id: onSemiLogo
                    source: "qrc:/images/on-semi-logo-horiz.svg"
                    anchors {
                        left: parent.left
                        leftMargin: 15
                        verticalCenter: parent.verticalCenter
                    }
                    height: (10/13) * parent.height
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                }
            }

            SGIcon {
                id: aboutIcon

                Layout.alignment: Qt.AlignTop
                Layout.margins: 10
                source: "qrc:/sgimages/info-circle.svg"
                height: 30
                width: 30
                iconColor: helpMouseArea.containsMouse ? "black" : "grey"

                MouseArea {
                    id: helpMouseArea
                    anchors {
                        fill: aboutIcon
                    }
                    hoverEnabled: true
                    onClicked: {
                        showAboutWindow()
                    }
                }
            }
        }

        Item {
            id: loginArea
            Layout.fillWidth: true
            Layout.fillHeight: true

            ScrollView {
                id: loginAreaScroll
                anchors {
                    fill: loginArea
                }
                contentHeight: centeringContainer.height
                contentWidth: centeringContainer.width

                Item {
                    id: centeringContainer
                    width: Math.max(loginContainer.width, loginArea.width)
                    height: Math.max(loginContainer.height, loginArea.height)

                    Rectangle {
                        id: loginContainer
                        width: 800
                        height: loginContainerColumn.height + 40
                        layer.enabled: true
                        layer.effect: DropShadow {
                            horizontalOffset: 10
                            verticalOffset: 10
                            samples: 17
                            color: "#40000000"
                        }
                        anchors {
                            centerIn: parent
                            verticalCenterOffset: -50
                        }

                        ColumnLayout {
                            id: loginContainerColumn
                            anchors {
                                centerIn: loginContainer
                            }
                            width: parent.width - 40
                            spacing: 20

                            Image {
                                id: strataLogo
                                Layout.alignment: Qt.AlignHCenter
                                Layout.maximumHeight: 155
                                Layout.preferredHeight: 155
                                Layout.fillHeight: true
                                fillMode: Image.PreserveAspectFit
                                source: "qrc:/images/strata-logo.svg"
                                mipmap: true
                            }

                            RowLayout {
                                id: selectionButtons
                                Layout.fillWidth: false
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 0

                                enabled: !(loginControls.connecting || registerControls.connecting || sessionControls.connecting)

                                SelectionButton {
                                    checked: true
                                    text: "Login"
                                    Accessible.role: Accessible.Button

                                    onClicked: {
                                        loginControls.visible = true
                                        registerControls.visible = false
                                    }
                                }

                                SelectionButton {
                                    text: "Register"
                                    Accessible.role: Accessible.Button

                                    onClicked: {
                                        loginControls.visible = false
                                        registerControls.visible = true
                                    }
                                }
                            }

                            ButtonGroup {
                                buttons: selectionButtons.children
                                exclusive: true
                            }

                            Item {
                                Layout.preferredHeight: height
                                Layout.fillWidth: true
                                height: controls.height
                                clip: true

                                Behavior on height {
                                    enabled: !(loginControls.animationsRunning || registerControls.animationsRunning)

                                    NumberAnimation {
                                        duration: 100
                                    }
                                }

                                ColumnLayout {
                                    id: controls
                                    anchors {
                                        centerIn: parent
                                    }
                                    width: 500

                                    SGSessionControls {
                                        id: sessionControls

                                        property alias loginControls: loginControls
                                    }

                                    SGLoginControls {
                                        id: loginControls
                                        visible: false

                                        property alias forgotPopup: forgotPopup
                                    }

                                    SGRegistrationControls {
                                        id: registerControls
                                        visible: false
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    SGForgotPassword {
        id: forgotPopup
        x: root.width/2 - width/2
        y: root.height/2 - height/2
    }

    Rectangle {
        id: testServerWarningContainer
        color: Theme.palette.error
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 30
        }
        height: testServerWarning.height + 30
        visible: sdsModel.urls.serverType !== "production"
        // Checks if the authServer is set to Non-Production server

        Text {
            id: testServerWarning
            color: "white"
            font.bold: true
            anchors {
                centerIn: parent
            }
            text: "NON-DEFAULT / TEST AUTHENTICATION SERVER ENABLED, POTENTIALLY UNSECURED, ONLY USE TEST CREDENTIALS.\nTEST AUTH SERVER REQUIRES VPN"
        }

        SGIcon {
            source: "qrc:/sgimages/exclamation-circle.svg"
            height: 30
            width: height
            iconColor: "white"
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                leftMargin: 10
            }
        }
    }

    // These text boxes are HACK solution to get around an issue on windows builds where the glyphs loaded in this file were the ONLY glyphs that appeared in subsequent views.
    // the effects of this bug are documented here: https://bugreports.qt.io/browse/QTBUG-62578 - our instance of this issue was not random as described, however.  --Faller
    Text {
        text: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890:./\\{}()[]-=+_!@#$%^&*`~<>?\"\'"
        font {
            family: Fonts.franklinGothicBold
        }
        visible: false
    }

    Text {
        text:  "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890:./\\{}()[]-=+_!@#$%^&*`~<>?\"\'"
        font {
            family: Fonts.franklinGothicBook
        }
        visible: false
    }

    function showAboutWindow() {
        SGDialogJS.createDialog(root, "qrc:partial-views/about-popup/DevStudioAboutWindow.qml")
    }
}
