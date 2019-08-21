import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import tech.strata.fonts 1.0

Popup {
    id: profilePopup
    width: container.width * 0.8
    height: container.parent.windowHeight * 0.8
    modal: true
    focus: true
    padding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    onClosed: profileStack.currentIndex=0

    DropShadow {
        width: profilePopup.width
        height: profilePopup.height
        horizontalOffset: 1
        verticalOffset: 3
        radius: 15.0
        samples: 30
        color: "#cc000000"
        source: profilePopup.background
        z: -1
        cached: true
    }

    Item {
        id: popupContainer
        width: profilePopup.width
        height: profilePopup.height
        clip: true

        Image {
            id: background
            source: "qrc:/images/login-background.svg"
            height: 1080
            width: 1920
            x: (popupContainer.width - width)/2
            y: (popupContainer.height - height)/2
        }

        Rectangle {
            id: title
            height: 30
            width: popupContainer.width
            anchors {
                top: popupContainer.top
            }
            color: "lightgrey"

            Label {
                id: profileTitle
                anchors {
                    left: title.left
                    leftMargin: 10
                    verticalCenter: title.verticalCenter
                }
                text: "My Profile"
                font {
                    family: Fonts.franklinGothicBold
                }
                color: "black"
            }

            SGIcon {
                id: close_profile
                iconColor: close_profile_hover.containsMouse ? "#eee" : "white"
                source: "qrc:/images/icons/times.svg"
                sourceSize.height: 20

                anchors {
                    right: title.right
                    verticalCenter: title.verticalCenter
                    rightMargin: 10
                }

                MouseArea {
                    id: close_profile_hover
                    anchors {
                        fill: close_profile
                    }
                    onClicked: profilePopup.close()
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }

        StackLayout {
            id: profileStack
            anchors {
                top: title.bottom
                left: popupContainer.left
                right: popupContainer.right
                bottom: popupContainer.bottom
            }
            currentIndex: 0

            ScrollView {
                id: scrollView
                Layout.fillWidth: true
                Layout.fillHeight: true

                contentHeight: contentContainer.height
                contentWidth: contentContainer.width
                clip: true

                Item {
                    id: contentContainer
                    width: Math.max(popupContainer.width, 600)
                    height: childrenRect.height
                    clip: true

                    Column {
                        id: mainColumn
                        spacing: 30
                        anchors {
                            top: contentContainer.top
                            right: contentContainer.right
                            left: contentContainer.left
                            margins: 15
                        }

                        Rectangle {
                            id: profileContainer
                            color: "#efefef"
                            width: mainColumn.width
                            height: 250
                            clip: true

                            Button {
                                text: "Update Profile"
                                anchors {
                                    top: profileContainer.top
                                    right: profileContainer.right
                                    margins: 15
                                }
                                onClicked: profileStack.currentIndex = 1
                            }

                            Image {
                                id: profile_image
                                anchors {
                                    verticalCenter: profileContainer.verticalCenter
                                    left: profileContainer.left
                                    leftMargin: 15
                                }
                                sourceSize.height: 220
                                fillMode: Image.PreserveAspectFit
                                source: "qrc:/images/" + "blank_avatar.png"
                            }

                            Item {
                                id: profileTextContainer
                                anchors {
                                    left: profile_image.right
                                    margins: 15
                                    right: profileContainer.right
                                    top: profileContainer.top
                                    bottom: profileContainer.bottom
                                }
                                clip: true

                                Column {
                                    spacing: 10

                                    Text {
                                        id: profile_username
                                        text: user_id
                                        font {
                                            pixelSize: 25
                                            family: Fonts.franklinGothicBold
                                        }
                                        color: "black"
                                    }

                                    Text {
                                        id: profile_email
                                        text: "Email: " + user_id + "@onsemi.com"
                                        font {
                                            pixelSize: 15
                                            family: Fonts.franklinGothicBook
                                        }
                                        color: "black"
                                    }

                                    Text {
                                        id: profile_userId
                                        text: "User ID: " + user_id
                                        font {
                                            pixelSize: 15
                                            family: Fonts.franklinGothicBook
                                        }
                                        color: "black"
                                    }

                                    Text {
                                        id: profile_phone
                                        text: "Phone: 123-123-5555"
                                        font {
                                            pixelSize: 15
                                            family: Fonts.franklinGothicBook
                                        }
                                        color: "black"
                                    }

                                    Text {
                                        id: jobTitle
                                        text : "Job Title: " //+ getJobTitle(user_id)
                                        color: "black"
                                        font {
                                            pixelSize: 15
                                            family: Fonts.franklinGothicBook
                                        }
                                    }

                                    Text {
                                        id: company
                                        text : "Company: Acme Inc."
                                        color: "black"
                                        font {
                                            pixelSize: 15
                                            family: Fonts.franklinGothicBook
                                        }
                                    }

                                    Text {
                                        id: companyAddress
                                        text: "Address: 9000 ACME Drive, Somewhere USA 91234"
                                        font {
                                            pixelSize: 15
                                            family: Fonts.franklinGothicBook
                                        }
                                        color: "black"
                                    }

                                    Text {
                                        id: onSemiContact
                                        text: "ON Semiconductor Contact: FAE/FSE/Disti/None"
                                        font {
                                            pixelSize: 15
                                            family: Fonts.franklinGothicBook
                                        }
                                        color: "black"
                                    }
                                }
                            }
                        }

                        Rectangle {
                            id: infoPrefsContainer
                            color: "#efefef"
                            width: mainColumn.width
                            height: infoPrefsTitle.height + prefsGrid.height + 30

                            Rectangle {
                                id: infoPrefsTitle
                                color: "#ddd"
                                width: infoPrefsContainer.width
                                height: 35

                                Text {
                                    id: infoPrefsTitleText
                                    text: "Product Information Preferences"
                                    font {
                                        pixelSize: 15
                                        family: Fonts.franklinGothicBook
                                    }
                                    anchors {
                                        verticalCenter: infoPrefsTitle.verticalCenter
                                        verticalCenterOffset: 2
                                        left: infoPrefsTitle.left
                                        leftMargin: 15
                                    }
                                }
                            }

                            Grid {
                                id: prefsGrid
                                anchors {
                                    top: infoPrefsTitle.bottom
                                    left: infoPrefsContainer.left
                                    right: infoPrefsContainer.right
                                    margins: 15
                                }
                                columns: 3
                                spacing: 2

                                SGGreenButton {
                                    text: "Connectivity, Custom, and SoC"
                                    width: (prefsGrid.width - prefsGrid.spacing * (prefsGrid.columns - 1)) / 3
                                    checkable: true
                                }

                                SGGreenButton {
                                    text: "Sensors"
                                    width: (prefsGrid.width - prefsGrid.spacing * (prefsGrid.columns - 1)) / 3
                                    checkable: true
                                }

                                SGGreenButton {
                                    text: "Power Management"
                                    checked: true
                                    width: (prefsGrid.width - prefsGrid.spacing * (prefsGrid.columns - 1)) / 3
                                    checkable: true
                                }

                                SGGreenButton {
                                    text: "Analog, Log, and Timing"
                                    width: (prefsGrid.width - prefsGrid.spacing * (prefsGrid.columns - 1)) / 3
                                    checkable: true
                                }

                                SGGreenButton {
                                    text: "Discrete"
                                    checked: true
                                    width: (prefsGrid.width - prefsGrid.spacing * (prefsGrid.columns - 1)) / 3
                                    checkable: true
                                }

                                SGGreenButton {
                                    text: "Optoelectronics"
                                    width: (prefsGrid.width - prefsGrid.spacing * (prefsGrid.columns - 1)) / 3
                                    checkable: true
                                }
                            }
                        }

                        Text {
                            id: cusomerSupport
                            text: "Customer Support: 1800-onsemi-support"
                            anchors{
                                horizontalCenter:  mainColumn.horizontalCenter
                            }
                            color: "black"
                            font {
                                pixelSize: 15
                                family: Fonts.franklinGothicBook
                            }
                        }
                    }
                }
            }

            SGProfileUpdate {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            SGPrivacyPolicy {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }

}
