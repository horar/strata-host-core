import QtQuick 2.7
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "qrc:/partial-views/login/"
import "qrc:/partial-views/"

import tech.strata.fonts 1.0
import tech.strata.logger 1.0
import tech.strata.sgwidgets 1.0

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

                    Item {
                        id: loginContainer
                        width: 800
                        height: loginContainerColumn.height + 40
                        anchors {
                            centerIn: parent
                            verticalCenterOffset: -50
                        }

                        Rectangle {
                            id: loginBackground
                            color: "white"
                            anchors {
                                fill: parent
                            }
                            visible: false
                            radius: 10
                        }

                        DropShadow {
                            anchors.fill: loginBackground
                            source: loginBackground
                            horizontalOffset: 10
                            verticalOffset: 10
                            radius: 8.0
                            samples: 17
                            color: "#40000000"
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

                                enabled: !(loginControls.connecting || registerControls.connecting)

                                SelectionButton {
                                    checked: true
                                    text: "Login"
                                    onClicked: {
                                        loginControls.visible = true
                                        registerControls.visible = false
                                    }
                                }

                                SelectionButton {
                                    text: "Register"
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

                                        property alias privacyPolicy: privacyPolicy
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

    SGPrivacyPolicyPopUp{
        id: privacyPolicy
        x: root.width/2 - width/2
        y: root.height/2 - height/2
        width: parent.width * .8
        webContainerHeight: root.height *.75
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
}
