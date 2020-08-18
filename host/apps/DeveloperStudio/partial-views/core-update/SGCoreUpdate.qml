import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "qrc:/partial-views"
import "../status-bar"

import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0
import tech.strata.logger 1.0

import "qrc:/js/core_update.js" as CoreUpdate
import tech.strata.CoreUpdate 1.0

SGStrataPopup {
    id: root
    headerText: "Update Detected"
    modal: true
    glowColor: "#666"
    closePolicy: Popup.CloseOnEscape
    implicitWidth: width

    property string latest_version: ""
    property string current_version: ""
    property string error_string: ""
    property bool dontaskagain_checked: false

    CoreUpdate {
        id: updateObj
    }

    contentItem: ColumnLayout {
        id: mainColumn
        spacing: 20

        Rectangle {
            id: updateContainer
            color: "transparent"
            Layout.preferredWidth: mainColumn.width
            Layout.preferredHeight: updateTextColumn.height + updateTextColumn.anchors.topMargin * 2
            Layout.topMargin: 5
            Layout.leftMargin: 5

            clip: true

            Row {
                id: updateTextColumn
                spacing: 5

                anchors {
                    top: updateContainer.top
                    topMargin: 5
                }

                SGIcon {
                    height: 70
                    width: height
                    source: "qrc:/sgimages/update-arrow.svg"
                    iconColor: "#3aba44"
                }

                Column {
                    spacing: 20

                    Text {
                        id: newVersionText
                        text: "New version of Developer Studio available!"
                        font {
                            pixelSize: 20
                            family: Fonts.franklinGothicBook
                            bold: true
                        }
                    }

                    Text {
                        id: currentVersionText
                        text: "Installed Version: " + "<b>" + current_version + "</b>"
                        font {
                            pixelSize: 18
                            family: Fonts.franklinGothicBook
                        }
                    }
                    Text {
                        id: latestVersionText
                        text: "Latest Version: " + "<b>" + latest_version + "</b>"
                        font {
                            pixelSize: 18
                            family: Fonts.franklinGothicBook
                        }
                    }
                }
            }
        }

        SGCheckBox {
            id: backupCheckbox
            Layout.alignment: Qt.AlignHCenter
            text: "Don't ask me again for this version"
            checked: dontaskagain_checked
        }

        Row {
            spacing: 20
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 50

            Button {
                id: updateButton
                text: "Update (will close Strata)"

                background: Rectangle {
                    color: !updateButton.enabled ? "#dbdbdb" : updateButton.down ? "#666" : "#888"
                    border.color: updateButton.activeFocus ? "#219647" : "transparent"
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
                  function checkReply(reply) {
                        if (reply !== "") {
                            console.error(Logger.devStudioCategory, "Received error message:", reply)
                            errorPopup.popupText = reply
                            errorPopup.open()
                        }
                    }

                    var askagain = backupCheckbox.checked ? "DontAskAgain" : "AskAgainLater"
                    CoreUpdate.setUserNotificationMode(askagain)
                    var reply = updateObj.requestUpdateApplication()

                    checkReply(reply)
                    root.close()
                }
            }

            Button {
                id: cancelButton
                text: "Cancel"

                background: Rectangle {
                    color: !cancelButton.enabled ? "#dbdbdb" : cancelButton.down ? "#666" : "#888"
                    border.color: cancelButton.activeFocus ? "#219647" : "transparent"
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
                    var askagain = backupCheckbox.checked ? "DontAskAgain" : "AskAgainLater"
                    CoreUpdate.setUserNotificationMode(askagain)
                    root.close()
                }
            }
        }
    }

    SGConfirmationPopup {
        id: errorPopup
        cancelButtonText: ""
        acceptButtonText: "OK"
        titleText: "Error"
        popupText: ""

        Connections {
            target: errorPopup.acceptButton
            onClicked: {
                errorPopup.close()
            }
        }
    }
}