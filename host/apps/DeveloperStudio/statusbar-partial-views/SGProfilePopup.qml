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

                        Rectangle {
                            id: privacyContainer
                            color: "#efefef"
                            width: mainColumn.width
                            height: privacyTitle.height + privacyColumn.height - 15

                            Column {
                                id: privacyColumn
                                spacing: 15

                                Rectangle {
                                    id: privacyTitle
                                    color: "#ddd"
                                    width: privacyContainer.width
                                    height: 35

                                    Text {
                                        id: privacyTitleText
                                        text: "Privacy Information"
                                        font {
                                            pixelSize: 15
                                            family: Fonts.franklinGothicBook
                                        }
                                        anchors {
                                            verticalCenter: privacyTitle.verticalCenter
                                            verticalCenterOffset: 2
                                            left: privacyTitle.left
                                            leftMargin: 15
                                        }
                                    }
                                }

                                Grid {
                                    id: privacyRow
                                    columns: buttonContainer.width + privacyRow.spacing + clearDataContainer.width > privacyContainer.width ? 1 : 2
                                    anchors {
                                        horizontalCenter: privacyColumn.horizontalCenter
                                    }
                                    spacing: 20
                                    horizontalItemAlignment: Grid.AlignHCenter

                                    Item {
                                        id: buttonContainer
                                        height: analyicsShow.height
                                        width: analyicsShow.width + privacyRow.spacing + policyShow.width
                                        Button {
                                            id: analyicsShow
                                            onClicked: profileStack.currentIndex = 2
                                            text: "View Analytics"
                                        }

                                        Button {
                                            id: policyShow
                                            onClicked: profileStack.currentIndex = 3
                                            text: "View Privacy Policy"
                                            anchors {
                                                right: buttonContainer.right
                                            }
                                        }
                                    }

                                    Item {
                                        id: clearDataContainer
                                        width: privacyButton.width
                                        height: clearDataColumn.height

                                        Column {
                                            id: clearDataColumn
                                            spacing: 10

                                            Button {
                                                id: privacyButton
                                                anchors {
                                                    horizontalCenter: clearDataColumn.horizontalCenter
                                                }
                                                text: "<b>Purge all Profile and Personal info from Strata Databases</b>"

                                                onClicked: {
                                                    privacyConfirmation.open()
                                                }
                                            }

                                            Text {
                                                id: privacyWarning
                                                text: "<font color='red'><strong>Warning:</strong></font> this action will result in unrecoverable loss of data"
                                                wrapMode: Text.WordWrap
                                                anchors {
                                                    horizontalCenter: clearDataColumn.horizontalCenter
                                                }
                                            }
                                        }
                                    }
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

            SGAnalyticsPopup {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            SGPrivacyPolicy {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }

    Popup {
        id: privacyConfirmation
        width: 500
        height: confirmationContainer.height
        x: profilePopup.width/2 - width/2
        y: profilePopup.height/2 - height/2
        modal: true
        padding: 0
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        DropShadow {
            width: privacyConfirmation.width
            height: privacyConfirmation.height
            horizontalOffset: 1
            verticalOffset: 3
            radius: 15.0
            samples: 30
            color: "#cc000000"
            source: privacyConfirmation.background
            z: -1
            cached: true
        }

        Rectangle {
            id: confirmationContainer
            width: privacyConfirmation.width
            height: childrenRect.height + column2.spacing

            Column {
                id: column2
                spacing: 20
                anchors {
                    left: confirmationContainer.left
                    right: confirmationContainer.right
                }

                Rectangle {
                    id: privacyConfirmTitleBox
                    height: 30
                    width: confirmationContainer.width
                    color: "lightgrey"

                    Label {
                        id: privacyConfirmTitle
                        anchors {
                            left: privacyConfirmTitleBox.left
                            leftMargin: 10
                            verticalCenter: privacyConfirmTitleBox.verticalCenter
                            verticalCenterOffset: 2
                        }
                        text: "Profile and Data Purge"
                        font {
                            family: Fonts.franklinGothicBook
                        }
                        color: "black"
                    }

                    SGIcon {
                        id: privacyConfirmTitleText
                        source: "qrc:/images/icons/times.svg"
                        iconColor: close_profile_hover.containsMouse ? "#eee" : "white"
                        sourceSize.height: 20

                        anchors {
                            right: privacyConfirmTitleBox.right
                            verticalCenter: privacyConfirmTitleBox.verticalCenter
                            rightMargin: 10
                        }

                        MouseArea {
                            id: closePrivacyConfirmMouse
                            anchors {
                                fill: privacyConfirmTitleText
                            }
                            onClicked: privacyConfirmation.close()
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                }

                Row {
                    anchors {
                        horizontalCenter: column2.horizontalCenter
                    }

                    Text {
                        color: "red"
                        text: "<b>Warning – this action will result in unrecoverable loss of data</b>"
                    }
                }

                Row {
                    id: row1
                    spacing: 20
                    anchors {
                        horizontalCenter: column2.horizontalCenter
                    }

                    Text {
                        text: "Do you wish to continue?"
                        anchors {
                            verticalCenter: row1.verticalCenter
                        }
                    }

                    Button {
                        text: "Accept"
                        onClicked: {
                            privacyConfirmation.close()
                        }
                    }

                    Button {
                        text: "Cancel"
                        onClicked: {
                            privacyConfirmation.close()
                        }
                    }
                }
            }
        }
    }
}
