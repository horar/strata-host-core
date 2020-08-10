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

    property string latest_version: ""
    property string current_version: ""
    property string error_string: ""

    onVisibleChanged: {
        if (visible) {
            nameField.forceActiveFocus()
        }
    }

    CoreUpdate {
        id: updateObj
    }

    contentItem: ColumnLayout {
        id: mainColumn
        spacing: 20

        Rectangle {
            id: feedbackTextContainer
            color: "transparent"
            Layout.preferredWidth: mainColumn.width
            Layout.preferredHeight: feedbackTextColumn.height + feedbackTextColumn.anchors.topMargin * 2
            clip: true

            Row {
                id: feedbackTextColumn
                spacing: 20
                width: feedbackTextContainer.width
                anchors {
                    top: feedbackTextContainer.top
                    topMargin: 15
                }

                SGIcon {
                    height: 70
                    width: height
                    source: "qrc:/sgimages/update-arrow.svg"
                    iconColor : "limegreen"
                    // anchors {
                    //     horizontalCenter: parent.horizontalCenter
                    // }
                }

                Column {
                    spacing: 20

                    Text {
                        id: newVersionText
                        text: "New version of Developer Studio available!"
                        font {
                            pixelSize: 18
                            family: Fonts.franklinGothicBook
                            bold: true
                        }
                        // lineHeight: 1.5
                        // width: feedbackTextContainer.width-30
                        // anchors {
                        //     horizontalCenter: feedbackTextColumn.horizontalCenter
                        // }
                        // horizontalAlignment: Text.AlignHCenter
                        // wrapMode: Text.Wrap
                        color: "black"
                    }

                    Text {
                        id: currentVersionText
                        text: "Current Version: " + current_version
                        font {
                            pixelSize: 14
                            family: Fonts.franklinGothicBook
                        }
                        // lineHeight: 1.5
                        // width: feedbackTextContainer.width-30
                        // anchors {
                        //     horizontalCenter: feedbackTextColumn.horizontalCenter
                        // }
                        // horizontalAlignment: Text.AlignHCenter
                        // wrapMode: Text.Wrap
                        color: "black"
                    }
                    Text {
                        id: latestVersionText
                        text: "Latest Version: " + latest_version
                        font {
                            pixelSize: 14
                            family: Fonts.franklinGothicBook
                        }
                        // lineHeight: 1.5
                        // width: feedbackTextContainer.width-30
                        // anchors {
                        //     horizontalCenter: feedbackTextColumn.horizontalCenter
                        // }
                        // horizontalAlignment: Text.AlignHCenter
                        // wrapMode: Text.Wrap
                        color: "black"
                    }
                }
            }
        }

        SGCheckBox {
            id: backupCheckbox
            Layout.alignment: Qt.AlignHCenter
            text: "Don't ask me again for this version"
        }

        Row {
            spacing: 20

            Button {
                id: updateButton
                text: "Update (will close Strata)"
                Layout.bottomMargin: 20
                Layout.alignment: Qt.AlignHCenter
                activeFocusOnTab: true

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
                        console.error(Logger.devStudioCategory, "inside error() function")
                        if (reply !== "") {
                            errorPopup.popupText = reply
                            errorPopup.open()
                        }
                    }

                    var askagain = backupCheckbox.checked ? "DontAskAgain" : "AskAgainLater"
                    CoreUpdate.setUserNotificationMode(askagain)
                    var reply = updateObj.requestUpdateApplication()

                    checkReply(reply)
                    console.error(Logger.devStudioCategory, "from qml UI received reply", reply)
                    root.close()
                }
            }

            Button {
                id: cancelButton
                text: "Cancel"
                Layout.bottomMargin: 20
                Layout.alignment: Qt.AlignHCenter
                activeFocusOnTab: true
                enabled: textEdit.text !== "" && feedbackTypeListView.currentIndex !== -1

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