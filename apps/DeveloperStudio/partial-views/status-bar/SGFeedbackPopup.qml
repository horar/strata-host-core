/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "qrc:/partial-views"
import "qrc:/partial-views/general/"
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/js/feedback.js" as Feedback

import tech.strata.fonts 1.0
import tech.strata.logger 1.0
import tech.strata.sgwidgets 1.0
import tech.strata.signals 1.0
import tech.strata.theme 1.0

SGStrataPopup {
    id: root
    headerText: "Strata Feedback"
    modal: true
    visible: true
    glowColor: "#666"
    closePolicy: Popup.CloseOnEscape
    width: container.width * 0.8
    height: 600
    x: container.width/2 - root.width/2
    y: mainWindow.height/2 - root.height/2

    onVisibleChanged: {
        if (visible) {
            nameField.forceActiveFocus()
        }
    }

    onClosed: {
        alertToast.hide()
        parent.active = false
    }

    contentItem: ColumnLayout {
        id: mainColumn

        ConnectionStatus {
            id: feedbackStatus
            visible: !feedbackWrapperColumn.visible
            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: root.width
            Layout.fillHeight: true
        }

        SGNotificationToast {
            id: alertToast
            Layout.preferredWidth: mainColumn.width
        }

        ColumnLayout{
            id: feedbackWrapperColumn

            Rectangle {
                id: feedbackTextContainer
                color: "#efefef"
                Layout.preferredWidth: mainColumn.width
                Layout.preferredHeight: feedbackTextColumn.height + feedbackTextColumn.anchors.topMargin * 2
                clip: true
                enabled: !feedbackStatus.visible


                Column {
                    id: feedbackTextColumn
                    spacing: 10
                    width: feedbackTextContainer.width
                    anchors {
                        top: feedbackTextContainer.top
                        topMargin: 15
                    }

                    Text {
                        id: feedbackText1
                        text: "onsemi would appreciate feedback on product usability, features, collateral, and quality of service. Please use this form to directly submit your feedback to our team."
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
                Layout.fillHeight: true

                ColumnLayout {
                    id: feedbackColumn
                    anchors {
                        fill: parent
                        margins: 20
                    }
                    spacing: 15

                    GridLayout {
                        id: personalGrid
                        columns: 2
                        rows: 3
                        rowSpacing: 3
                        columnSpacing: 3

                        Text {
                            id: nameForm
                            text: "Name:"

                            font {
                                pixelSize: 15
                                family: Fonts.franklinGothicBook
                            }
                        }

                        Text {
                            id: nameField
                            Layout.preferredWidth: feedbackColumn.width - nameForm.width
                            Layout.preferredHeight: nameForm.height
                            text: NavigationControl.context.first_name + " " + NavigationControl.context.last_name
                            elide: Text.ElideRight
                            textFormat: Text.PlainText

                            font {
                                pixelSize: 15
                                family: Fonts.franklinGothicBook
                            }
                        }

                        Text {
                            id: emailForm
                            text: "Email:"
                            font {
                                pixelSize: 15
                                family: Fonts.franklinGothicBook
                            }
                        }

                        Text {
                            id: emailField
                            Layout.preferredWidth: feedbackColumn.width - emailForm.width
                            Layout.preferredHeight: emailForm.height
                            text: NavigationControl.context.user_id
                            elide: Text.ElideRight

                            font {
                                pixelSize: 15
                                family: Fonts.franklinGothicBook
                            }
                        }
                    }

                    Text {
                        id: feedbackTypeText
                        text: "Please select a feedback type:"
                        font {
                            pixelSize: 15
                            family: Fonts.franklinGothicBook
                        }
                    }

                    ListView {
                        id: feedbackTypeListView
                        opacity: !feedbackStatus.visible ? 1 : 0.1
                        orientation: Qt.Horizontal
                        spacing: 5
                        enabled: !feedbackStatus.visible
                        model: SGFeedbackTypeModel {}
                        delegate: SGFeedbackTypeDelegate {}
                        currentIndex: -1
                        Layout.preferredHeight: 30
                        Layout.fillWidth: true

                        onCurrentIndexChanged: {
                            if(currentIndex !== -1 && alertToast.visible) alertToast.hide();
                        }
                    }

                    Text {
                        id: feedbackFormTitleText
                        text: "Any comments or questions:"
                        font {
                            pixelSize: 15
                            family: Fonts.franklinGothicBook
                        }
                    }

                    SGTextArea {
                        id: commentsQuestionsArea
                        enabled: !feedbackStatus.visible
                        contextMenuEnabled: true
                        // Text Length Limiter
                        readOnly: feedbackStatus.visible
                        KeyNavigation.tab: submitButton
                        KeyNavigation.priority: KeyNavigation.BeforeItem
                        Accessible.role: Accessible.EditableText
                        Accessible.name: "FeedbackEdit"
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        palette.highlight: Theme.palette.onsemiOrange

                        property int maximumLength: 1000
                        property string previousText: text

                        onTextChanged: {
                            if(alertToast.visible) alertToast.hide();

                            if (text.length > maximumLength) {
                                var cursor = commentsQuestionsArea.cursorPosition
                                text = previousText;
                                if (cursor > text.length) {
                                    commentsQuestionsArea.cursorPosition = text.length;
                                } else {
                                    commentsQuestionsArea.cursorPosition = cursor - 1;
                                }
                            }
                            previousText = text
                        }
                    }

                    SGText {
                        id: charactersRemainingText
                        Layout.alignment: Qt.AlignLeft
                        opacity: charactersRemaining === 0 ? 1 : 0.4
                        text: charactersRemaining === 1 ? charactersRemaining + " character remaining" : charactersRemaining + " characters remaining"
                        font {
                            pixelSize: 15
                            family: Fonts.franklinGothicBook
                        }
                        color: {
                            if (charactersRemaining === 0) {
                                return Theme.palette.red
                            } else {
                                return Theme.palette.black
                            }
                        }

                        property int charactersRemaining: commentsQuestionsArea.maximumLength - commentsQuestionsArea.text.length
                    }

                    Button {
                        id: submitButton
                        text: "Submit"
                        Layout.alignment: Qt.AlignHCenter
                        activeFocusOnTab: true
                        enabled: commentsQuestionsArea.text.match(/\S/) && feedbackTypeListView.currentIndex !== -1 && !feedbackStatus.visible

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

                        Keys.onReturnPressed: pressSubmitButton()
                        Accessible.onPressAction: pressSubmitButton()

                        onClicked: {
                            if (alertToast.visible) {
                                alertToast.hideInstantly()
                            }
                            var feedbackInfo = { email: emailField.text, name: nameField.text,  comment: commentsQuestionsArea.text, type: feedbackTypeListView.currentItem.typeValue }
                            feedbackStatus.currentId = Feedback.getNextId()
                            Feedback.feedbackInfo(feedbackInfo)
                            feedbackWrapperColumn.visible = false
                        }

                        function pressSubmitButton() {
                            submitButton.clicked()
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: Signals

        onFeedbackResult: {
            feedbackStatus.text = ""
            feedbackWrapperColumn.visible = true
            if (result === "Feedback successfully sent") {
                alertToast.color = "#57d445"
                alertToast.text = "Feedback successfully submitted!"
                root.resetForm()
            } else {
                alertToast.color = "red"
                if (result === "No Connection") {
                    alertToast.text = "No connection to feedback server! Please check your internet connection and try again."
                } else if (result === "Server Error") {
                    alertToast.text = "Feedback server is unable to process your request at this time! Please try again later."
                } else if (result === "Invalid Authentication") {
                    alertToast.text = "Feedback server is unable to authenticate your request! Please try to log out and back in."
                } else {
                    alertToast.text = "Failed to submit feedback! Please verify your input and try again."
                }
            }
            alertToast.show()
        }
    }

    function resetForm(){
        commentsQuestionsArea.text = ""
        feedbackTypeListView.currentIndex = -1
    }
}
