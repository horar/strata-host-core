import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "qrc:/partial-views"
import "qrc:/js/feedback.js" as Feedback
import "qrc:/js/navigation_control.js" as NavigationControl
import "../login/"

import tech.strata.fonts 1.0
import tech.strata.logger 1.0

SGStrataPopup {
    id: root
    headerText: "Strata Feedback"
    modal: true
    glowColor: "#666"
    closePolicy: Popup.CloseOnEscape

    onVisibleChanged: {
        if (visible) {
            nameField.forceActiveFocus()
        }
    }

    contentItem: ColumnLayout {
        id: mainColumn
        spacing: 20

        Rectangle {
            id: feedbackTextContainer
            color: "#efefef"
            Layout.preferredWidth: mainColumn.width
            Layout.preferredHeight: feedbackTextColumn.height + feedbackTextColumn.anchors.topMargin * 2
            clip: true

            Column {
                id: feedbackTextColumn
                spacing: 20
                width: feedbackTextContainer.width
                anchors {
                    top: feedbackTextContainer.top
                    topMargin: 15
                }

                Text {
                    id: feedbackText1
                    text: "ON Semiconductor would appreciate feedback on product usability, features, collateral, and quality of service. Please use this form to directly submit your feedback to our Strata Developer Studio team."
                    font {
                        pixelSize: 15
                        family: Fonts.franklinGothicBook
                    }
                    lineHeight: 1.5
                    width: feedbackTextContainer.width-30
                    anchors {
                        horizontalCenter: feedbackTextColumn.horizontalCenter
                    }
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    color: "black"
                }

                Column {
                    id: subColumn
                    anchors {
                        horizontalCenter: feedbackTextColumn.horizontalCenter
                    }

                    Text {
                        id: feedbackText2
                        text: "Thank you,"
                        font {
                            pixelSize: 15
                            family: Fonts.franklinGothicBook
                        }
                        lineHeight: 1.5
                        width: feedbackTextContainer.width-30
                        anchors {
                            horizontalCenter: subColumn.horizontalCenter
                        }
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap
                        color: "black"
                    }

                    Text {
                        id: feedbackText3
                        text: "Strata Developer Studio Team"
                        font {
                            pixelSize: 15
                            family: Fonts.franklinGothicBook
                        }
                        width: feedbackTextContainer.width-30
                        anchors {
                            horizontalCenter: subColumn.horizontalCenter
                        }
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap
                        color: "black"
                    }
                }
            }
        }



        Rectangle {
            id: feedbackFormContainer
            color: "#efefef"
            Layout.preferredWidth: mainColumn.width
            Layout.preferredHeight: personalGrid.height + feedbackTypeContainer.height + feedbackColumn.height + submitButton.height + personalGrid.anchors.topMargin

            GridLayout {
                id: personalGrid
                anchors {
                    top: feedbackFormContainer.top
                    left: feedbackFormContainer.left
                    topMargin: 20
                    leftMargin: 15
                }

                columns: 2

                Text {
                    text: "Name:"

                    font {
                        pixelSize: 15
                        family: Fonts.franklinGothicBook
                    }
                }

                Text {
                    id: nameField
                    text: NavigationControl.context.first_name + " " + NavigationControl.context.last_name
                    font {
                        pixelSize: 15
                        family: Fonts.franklinGothicBook
                    }
                }

                Text {
                    text: "Email:"
                    font {
                        pixelSize: 15
                        family: Fonts.franklinGothicBook
                    }
                }

                Text {
                    id: emailField
                    text: NavigationControl.context.user_id
                    font {
                        pixelSize: 15
                        family: Fonts.franklinGothicBook
                    }
                }
            }

            Rectangle {
                id: feedbackTypeContainer

                width: parent.width
                height: feedbackTypeText.height + 40

                anchors {
                    top: personalGrid.bottom
                    left: feedbackFormContainer.left
                    topMargin: 20
                    leftMargin: 15
                }

                color: "transparent"

                Text {
                    id: feedbackTypeText
                    width: parent.width
                    anchors.top: parent.top
                    text: "Please select a feedback type:"

                    font {
                        pixelSize: 15
                        family: Fonts.franklinGothicBook
                    }
                }

                ListView {
                    id: feedbackTypeListView

                    width: parent.width

                    anchors {
                        top: feedbackTypeText.bottom
                        topMargin: 10
                    }

                    orientation: Qt.Horizontal
                    spacing: 5
                    model: SGFeedbackTypeModel {}
                    delegate: SGFeedbackTypeDelegate {}
                    currentIndex: -1
                }
            }

            ColumnLayout {
                id: feedbackColumn
                width: feedbackFormContainer.width
                anchors {
                    top: feedbackTypeContainer.bottom
                    left: feedbackFormContainer.left
                    right: feedbackFormContainer.right
                    topMargin: 20
                    leftMargin: 15
                    rightMargin: 15
                }
                spacing: 10

                Text {
                    id: feedbackFormTitleText

                    Layout.fillWidth: true

                    text: "Any comments or questions:"
                    font {
                        pixelSize: 15
                        family: Fonts.franklinGothicBook
                    }
                }

                Rectangle {
                    id: textEditContainer
                    color: "white"
                    border {
                        width: 1
                        color: "lightgrey"
                    }
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200
                    clip: true

                    ScrollView {
                        id: scrollingText
                        anchors {
                            fill: textEditContainer
                            margins: 10
                        }

                        TextEdit {
                            Accessible.role: Accessible.EditableText
                            Accessible.name: "FeedbackEdit"


                            id: textEdit
                            width: scrollingText.width
                            wrapMode: TextEdit.Wrap
                            height: Math.max(scrollingText.height, contentHeight)

                            // Text Length Limiter
                            property int maximumLength: 1000
                            property string previousText: text
                            onTextChanged: {
                                if (text.length > maximumLength) {
                                    var cursor = cursorPosition;
                                    text = previousText;
                                    if (cursor > text.length) {
                                        cursorPosition = text.length;
                                    } else {
                                        cursorPosition = cursor-1;
                                    }
                                }
                                previousText = text
                            }
                            KeyNavigation.tab: submitButton
                            KeyNavigation.priority: KeyNavigation.BeforeItem
                        }
                    }
                }

                Button {
                    Accessible.onPressAction: function() {
                        clicked();
                    }

                    id: submitButton
                    text: "Submit"
                    Layout.bottomMargin: 20
                    Layout.alignment: Qt.AlignHCenter
                    activeFocusOnTab: true
                    enabled: textEdit.text !== "" && feedbackTypeListView.currentIndex !== -1

                    background: Rectangle {
                        color: !submitButton.enabled ? "#dbdbdb" : submitButton.down ? "#666" : "#888"
                        border.color: submitButton.activeFocus ? "#219647" : "transparent"
                    }

                    contentItem: Text {
                        text: submitButton.text
                        color: !submitButton.enabled ? "#f2f2f2" : "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                        font {
                            pixelSize: 15
                            family: Fonts.franklinGothicBold
                        }
                    }

                    Keys.onReturnPressed:{
                        submitButton.clicked()
                    }

                    onClicked: {
                        var feedbackInfo = { email: emailField.text, name: nameField.text,  comment: textEdit.text, type: feedbackTypeListView.currentItem.typeValue }
                        function success() {
                            confirmPopup.open()
                            feedbackTypeListView.currentIndex = -1
                        }

                        function error(response) {
                            if (response.message === "No connection") {
                                errorPopup.popupText = "No Internet Connection"
                            } else {
                                errorPopup.popupText = "Error: Could not process your request."
                            }
                            errorPopup.open()
                        }
                        Feedback.feedbackInfo(feedbackInfo, success, error)
                    }
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
                //root.close()
                errorPopup.close()
            }
        }
    }

    SGConfirmationPopup {
        id: confirmPopup
        cancelButtonText: ""
        acceptButtonText: "OK"
        titleText: "Submit Feedback Success"
        popupText: "Thank you for your feedback!"

        Connections {
            target: confirmPopup.acceptButton
            onClicked: {
                root.close()
                confirmPopup.close()
                textEdit.text = ""
            }
        }
    }
}
