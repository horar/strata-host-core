/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "qrc:/partial-views"
import "../status-bar"
import '../'

import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0
import tech.strata.logger 1.0
import tech.strata.theme 1.0

import "qrc:/js/core_update.js" as CoreUpdate

SGStrataPopup {
    id: root
    headerText: "Update Strata Developer Studio"
    modal: true
    glowColor: "#666"
    closePolicy: Popup.CloseOnEscape
    implicitWidth: width

    property string error_string: ""
    property bool dontaskagain_checked: false
    property bool checking_for_updates: false

    contentItem: ColumnLayout {
        id: mainColumn
        spacing: 10

        ScrollView {
            id: statusInfoScrollView
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: CoreUpdate.update_model.count === 0
            clip: true

            TextArea {
                id: statusInfoTextArea
                wrapMode: TextArea.Wrap
                text: {
                    if (error_string !== "") {
                        return error_string
                    } else if (checking_for_updates) {
                        return "Checking for updates..."
                    } else {
                        return "No updates are available."
                    }
                }
                color: error_string !== "" ? Theme.palette.error : Theme.palette.black
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                readOnly: true
                font {
                    pixelSize: 18
                    family: Fonts.franklinGothicBook
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: CoreUpdate.update_model.count > 0
            spacing: 10

            RowLayout {
                id: updateTextColumn
                spacing: 5

                SGIcon {
                    id: updateIcon
                    height: 30
                    width: height - 5
                    source: "qrc:/sgimages/update-arrow.svg"
                    iconColor: "#3aba44"
                }

                SGText {
                    id: updatesText
                    text: "Updates are available!"
                    fontSizeMultiplier: 1.75
                    font {
                        family: Fonts.franklinGothicBook
                        bold: true
                    }
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignBottom
                }
            }

            ListView {
                id: updateListView
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.topMargin: 5
                Layout.leftMargin: 10
                Layout.rightMargin: 5
                clip: true
                model: CoreUpdate.update_model
                boundsBehavior: Flickable.StopAtBounds
                spacing: 20

                ScrollBar.vertical: ScrollBar {
                    id: verticalScrollback
                    width: 12
                    policy: ScrollBar.AlwaysOn
                    visible: updateListView.height < updateListView.contentHeight
                }

                delegate: RowLayout {
                    id: updateDelegate
                    width: updateListView.width - verticalScrollback.width
                    property bool expanded: false

                    ColumnLayout {
                        spacing: 5
                        Layout.alignment: Qt.AlignTop
                        SGText {
                            fontSizeMultiplier: 1.5
                            font.bold: true
                            font.family: Fonts.franklinGothicBook
                            text: {
                                let name_info = "<b>" + model.name + "</b>"
                                if (updateDelegate.expanded === false)
                                    name_info += " v" + model.latest_version
                                return name_info
                            }
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            Layout.topMargin: 5
                        }

                        GridLayout {
                            columns: 2
                            rowSpacing: 5

                            SGText {
                                fontSizeMultiplier: 1.4
                                font.family: Fonts.franklinGothicBook
                                text: "New Version: "
                                visible: updateDelegate.expanded
                                Layout.alignment: Qt.AlignTop
                            }

                            SGText {
                                fontSizeMultiplier: 1.4
                                font.family: Fonts.franklinGothicBook
                                text: {
                                    let version_info = "<b>" + model.latest_version + "</b>"
                                    version_info += " (" + model.update_size + ")"
                                    return version_info
                                }
                                visible: updateDelegate.expanded
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignTop
                                wrapMode: Text.Wrap
                            }

                            SGText {
                                fontSizeMultiplier: 1.4
                                font.family: Fonts.franklinGothicBook
                                text: "Current Version: "
                                visible: updateDelegate.expanded && (model.current_version !== "N/A")
                                Layout.alignment: Qt.AlignTop
                            }

                            SGText {
                                fontSizeMultiplier: 1.4
                                font.family: Fonts.franklinGothicBook
                                text: "<b>" + model.current_version + "</b>"
                                visible: updateDelegate.expanded && (model.current_version !== "N/A")
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignTop
                                wrapMode: Text.Wrap
                            }
                        }
                    }

                    SGIconButton {
                        id: expandIconButton
                        icon.source: updateDelegate.expanded ? "qrc:/sgimages/chevron-up.svg" : "qrc:/sgimages/chevron-down.svg"
                        iconSize: 20
                        hintText: updateDelegate.expanded ? "Show less information" : "Show additional information"
                        iconColor: "grey"
                        onClicked: {
                            updateDelegate.expanded = !updateDelegate.expanded
                        }
                        Layout.alignment: Qt.AlignTop
                    }
                }
            }

            SGCheckBox {
                id: backupCheckbox
                Layout.alignment: Qt.AlignLeft
                text: "Don't ask me again for these versions"
                checked: dontaskagain_checked
            }
        }

        RowLayout {
            id: buttonsRow
            spacing: 20
            Layout.alignment: Qt.AlignHCenter

            Button {
                id: updateButton
                text: CoreUpdate.update_model.count > 0 ? "Update all (will close Strata)" : "Check for Updates"

                background: Rectangle {
                    color: !updateButton.enabled ? "#dbdbdb" : updateButton.down ? "#666" : "#888"
                    border.color: updateButton.activeFocus ? Theme.palette.onsemiOrange : "transparent"
                }

                contentItem: Text {
                    text: updateButton.text
                    color: !updateButton.enabled ? "#f2f2f2" : "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    font {
                        pixelSize: 15
                        family: Fonts.franklinGothicBold
                    }
                }

                onClicked: {
                    if (CoreUpdate.update_model.count > 0) {
                        var reply = coreUpdate.requestUpdateApplication()
                        if (reply !== "") {
                            console.error(Logger.devStudioCategory, "Received error message:", reply)
                            errorPopup.popupText = reply
                            errorPopup.open()
                        } else {
                            root.close()
                        }
                    } else {
                        CoreUpdate.getUpdateInformation()
                    }
                }
            }

            Button {
                id: cancelButton
                text: "Cancel"

                background: Rectangle {
                    color: !cancelButton.enabled ? "#dbdbdb" : cancelButton.down ? "#666" : "#888"
                    border.color: cancelButton.activeFocus ? Theme.palette.onsemiOrange : "transparent"
                }

                contentItem: Text {
                    text: cancelButton.text
                    color: !cancelButton.enabled ? "#f2f2f2" : "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    font {
                        pixelSize: 15
                        family: Fonts.franklinGothicBold
                    }
                }

                onClicked: {
                    root.close()
                }
            }
        }
    }

    onAboutToHide: {
        var askagain = backupCheckbox.checked ? "DontAskAgain" : "AskAgainLater"
        CoreUpdate.setUserNotificationMode(askagain)
    }

    onClosed: {
        CoreUpdate.removeUpdatePopup()
    }

    SGConfirmationPopup {
        id: errorPopup
        titleText: "Error when trying to perform software update"
        popupText: ""

        property var closeButtonObject: [{
            buttonText: closeButtonText,
            buttonColor: closeButtonColor,
            buttonHoverColor: closeButtonHoverColor,
            closeReason: popupCloseReason
        }]
        property color closeButtonColor: "#999"
        property color closeButtonHoverColor: "#666"
        property string closeButtonText: "Close"
        readonly property int popupCloseReason: 2

        buttons: closeButtonObject
    }
}
