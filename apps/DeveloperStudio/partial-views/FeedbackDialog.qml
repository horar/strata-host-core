/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.sgwidgets 2.0 as SGWidgets2
import tech.strata.theme 1.0
import tech.strata.fonts 1.0
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/js/restclient.js" as Rest
import "qrc:/js/utilities.js" as Utility
import tech.strata.logger 1.0 as LoggerModule

import "./general"


SGStrataPopup {
    id: dialog
    x: ApplicationWindow.window.width/2 - dialog.width/2
    y: ApplicationWindow.window.height/2 - dialog.height/2
    width: ApplicationWindow.window.width * 0.8
    height: 600

    headerText: "Feedback"
    closePolicy: Dialog.CloseOnEscape
    modal: true
    focus: true
    visible: true

    onClosed: {
        parent.active = false
    }

    property bool showDetails: false
    property var feedbackType: FeedbackDialog.ReportIssue
    property bool submitInProgress: false
    property string comment: ""
    property var additionalDetailsData: ({})
    property bool sendDetails: true

    enum FeedbackType {
        ReportIssue,
        FeatureRequest,
        Acknowledgement
    }

    contentItem: Item {
        id: content
        width: dialog.width - dialog.leftPadding - dialog.rightPadding
        height: dialog.height - dialog.topPadding - dialog.bottomPadding

        SGNotificationToast {
            id: alertToast
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
        }

        StackView {
            id: stackView
            anchors {
                top: alertToast.bottom
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }

            focus: true
            initialItem: welcomePageComponent
            clip: true
            pushEnter: null
            pushExit: null
            popEnter: null
            popExit: null

            visible: submitInProgress === false
        }

        ConnectionStatus {
            id: feedbackStatus
            visible: submitInProgress
            anchors.centerIn: parent
        }
    }

    Component {
        id: welcomePageComponent

        Item {
            SGWidgets2.SGText {
                id: thankyouText
                width: parent.width
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: 15
                }

                font {
                    pixelSize: 15
                    family: Fonts.franklinGothicBook
                }
                text: "onsemi would appreciate feedback on product usability, features, collateral, and quality of service. Please select the most appropriate option to directly submit your feedback to our team.\n\nThank you,\nStrata Developer Studio Team"
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                lineHeight: 1.5
            }

            ColumnLayout {
                anchors {
                    top: thankyouText.bottom
                    topMargin: 40
                    horizontalCenter: parent.horizontalCenter
                }

                spacing: 20

                SGWidgets2.SGButton {
                    text: "Acknowledgement"
                    buttonSize: SGWidgets2.SGButton.Large
                    Layout.preferredWidth: 300
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: {
                        feedbackType = FeedbackDialog.Acknowledgement
                        stackView.push(commentPageComponent)
                    }
                }

                SGWidgets2.SGButton {
                    text: "Feature Request"
                    buttonSize: SGWidgets2.SGButton.Large
                    Layout.preferredWidth: 300
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: {
                        feedbackType = FeedbackDialog.FeatureRequest
                        stackView.push(commentPageComponent)
                    }
                }

                SGWidgets2.SGButton {
                    text: "Report Issue"
                    buttonSize: SGWidgets2.SGButton.Large
                    Layout.preferredWidth: 300
                    Layout.alignment: Qt.AlignHCenter
                    Accessible.onPressAction: {
                        clicked()
                    }
                    onClicked: {
                        feedbackType = FeedbackDialog.ReportIssue
                        stackView.push(commentPageComponent)
                    }
                }
            }
        }
    }

    Component {
        id: commentPageComponent

        FocusScope {
            SGWidgets2.SGText {
                id: feedbackTitle

                fontSizeMultiplier: 2.0
                font.bold: true
                text: {
                    if (feedbackType === FeedbackDialog.ReportIssue) {
                        return "Report Issue"
                    } else if (feedbackType === FeedbackDialog.FeatureRequest) {
                        return "Feature Request"
                    }

                    return "Acknowledgement"
                }
            }

            FocusScope {
                id: commentWrapper

                anchors {
                    top: feedbackTitle.bottom
                    topMargin: 12
                    bottom: userInfoText.top
                    bottomMargin: 0
                    left: parent.left
                    right: parent.right
                }

                focus: true

                SGWidgets2.SGText {
                    id: commentText
                    anchors {
                        top: parent.top

                    }

                    text:"Comments"
                    fontSizeMultiplier: 1.1
                }

                SGWidgets.SGTextArea {
                    id: commentArea
                    anchors {
                        top: commentText.bottom
                        topMargin: 1
                        bottom: charCounter.top
                        bottomMargin: 2
                        left: parent.left
                        right: parent.right
                    }

                    focus: true
                    contextMenuEnabled: true
                    Accessible.role: Accessible.EditableText
                    Accessible.name: "CommentArea"
                    palette.highlight: Theme.palette.onsemiOrange
                    placeholderText: {
                        if (feedbackType === FeedbackDialog.ReportIssue) {
                            return "Provide any steps nessesary to reproduce the problem"
                        } else if (feedbackType === FeedbackDialog.FeatureRequest) {
                            return "Provide description of proposed functionality"
                        }

                        return "Any comments or questions"
                    }

                    property int maximumLength: 1000

                    onTextChanged: {
                        if (alertToast.visible) {
                            alertToast.hide()
                        }

                        if (text.length > maximumLength) {
                            truncateTextTimer.start()
                        }
                    }

                    Timer {
                        id: truncateTextTimer
                        interval: 100
                        onTriggered: {
                            if (commentArea.text.length > commentArea.maximumLength) {
                                var newCursorPosition = Math.min(commentArea.cursorPosition, commentArea.maximumLength)
                                commentArea.text = commentArea.text.substring(0, commentArea.maximumLength)
                                commentArea.cursorPosition = newCursorPosition
                            }
                        }
                    }

                    Binding {
                        target: dialog
                        property: "comment"
                        value: commentArea.text
                    }
                }

                SGWidgets2.SGText {
                    id: charCounter
                    anchors {
                        right: parent.right
                        bottom: parent.bottom
                    }

                    font.family: "monospace"
                    text: commentArea.text.length + "/" + commentArea.maximumLength
                    color: {
                        if (commentArea.text.length >= commentArea.maximumLength) {
                            return Theme.palette.error
                        }

                        return Theme.palette.black
                    }
                }
            }

            SGWidgets2.SGText {
                id: userInfoText
                anchors {
                    bottom: detailWrapper.visible ? detailWrapper.top : parent.bottom
                    bottomMargin: detailWrapper.visible ? 12 : 0
                }

                fontSizeMultiplier: 1.1
                text: {
                    var t = ""
                    t += "Name: " + NavigationControl.context.first_name + " " + NavigationControl.context.last_name + "\n"
                    t += "Email: "+NavigationControl.context.user_id
                    return t
                }
            }

            Item {
                id: detailWrapper
                height: detailArea.y + detailArea.height
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                }

                SGWidgets.SGCheckBox {
                    id: issueDetailsCheckbox
                    anchors {
                        top: parent.top
                    }

                    checked: true
                    padding: 0
                    text: "Attach additional details"
                    focusPolicy: Qt.NoFocus

                    onCheckedChanged: {
                        sendDetails = checked
                    }

                    Binding {
                        target: issueDetailsCheckbox
                        property: "checked"
                        value: sendDetails
                    }
                }

                SGWidgets.SGTextArea {
                    id: detailArea
                    anchors {
                        top: issueDetailsCheckbox.bottom
                        topMargin: 2
                        left: parent.left
                        right: parent.right
                    }

                    height: showDetails ? 160 : 0
                    Behavior on height { NumberAnimation { duration: 100 }}

                    readOnly: true
                    contextMenuEnabled: true
                    palette.highlight: Theme.palette.onsemiOrange
                    opacity: issueDetailsCheckbox.checked ? 1 : 0.4
                    activeFocusOnPress: false
                    focus: false
                    text: JSON.stringify(additionalDetailsData, null,"  ")

                }

                Binding {
                    target: dialog
                    property: "additionalDetailsData"
                    value: {
                        var activeTabData = {}
                        if (NavigationControl.stack_container_.currentIndex === 0) {
                            //platform selector
                            activeTabData["type"] = "platform_selector"
                        } else if (NavigationControl.stack_container_.currentIndex > 0
                                   && NavigationControl.stack_container_.currentIndex < NavigationControl.stack_container_.count - 1) {
                            //platforms
                            activeTabData["type"] = "platform"

                            var item = NavigationControl.stack_container_.platformViewModel.get(NavigationControl.stack_container_.currentIndex - 1)
                            activeTabData["class_id"] = item["class_id"]
                            activeTabData["device_id"] = item["device_id"]
                            activeTabData["name"] = item["name"]
                        } else if (NavigationControl.stack_container_.currentIndex === NavigationControl.stack_container_.count - 1) {
                            //control view creator
                            activeTabData["type"] = "control_view_creator"
                        } else {
                            activeTabData["type"] = "unknown"
                        }

                        return {
                            "platforms": JSON.parse(sdsModel.coreInterface.connectedPlatformList),
                            "active_tab": activeTabData,
                        }
                    }
                }
            }
        }
    }

    footer: Item {
        implicitHeight: submitButton.height + 10
        visible: stackView.depth > 1 && submitInProgress === false

        SGWidgets2.SGButton {
            anchors {
                left: parent.left
                leftMargin: 10
                top: parent.top
            }

            text: showDetails ? "Hide Details" : "Show Details"
            onClicked: {
                showDetails = !showDetails
            }
        }

        SGWidgets2.SGButton {
            id: submitButton
            anchors {
                right: parent.right
                rightMargin: 10
                top: parent.top
            }

            text: "Submit"
            enabled: dialog.comment.trim().length > 1
            Accessible.onPressAction: {
                clicked()
            }
            onClicked: {
                sendFeedback()
            }
        }
    }

    function sendFeedback() {
        if (alertToast.visible) {
            alertToast.hideInstantly()
        }

        let headers = {
            "app": "strata",
            "version": Rest.versionNumber(),
        }

        let data = {
            "email": NavigationControl.context.user_id,
            "name": NavigationControl.context.first_name + " " + NavigationControl.context.last_name,
            "comment": dialog.comment,
        }

        if (sendDetails) {
            for (const key in additionalDetailsData) {
                if (additionalDetailsData.hasOwnProperty(key)) {
                    data[key] = additionalDetailsData[key]
                }
            }
        }

        var type = ""
        if (feedbackType === FeedbackDialog.ReportIssue) {
            type = "Bug"
        } else if (feedbackType === FeedbackDialog.FeatureRequest) {
            type = "Feature"
        } else if (feedbackType === FeedbackDialog.Acknowledgement) {
            type = "Acknowledgement"
        }

        data["type"] = type

        feedbackStatus.currentId = Rest.getNextRequestId();

        console.log(LoggerModule.Logger.devStudioFeedbackCategory, "feedback message:", JSON.stringify(data))
        Rest.xhr("post", "feedbacks", data, feedbackCallback, feedbackCallbackError, headers);

        submitInProgress = true
    }

    function feedbackCallback(response) {
        console.log(LoggerModule.Logger.devStudioFeedbackCategory, "Feedback successfully sent")

        submitInProgress = false
        alertToast.color = Theme.palette.success
        alertToast.text = "Feedback successfully submitted!"

        alertToast.show()

        //reset forms
        stackView.pop()
        stackView.push(commentPageComponent)
    }

    function feedbackCallbackError(response) {
        console.log(LoggerModule.Logger.devStudioFeedbackCategory, "Feedback failed to send: ", JSON.stringify(response))

        submitInProgress = false
        alertToast.color = Theme.palette.error

        if (response.message === "No connection") {
            alertToast.text = "No connection to feedback server! Please check your internet connection and try again."
        } else if (response.message === 'Response not valid') {
            alertToast.text = "Feedback server is unable to process your request at this time! Please try again later."
        } else if ((response.message === 'Invalid authentication token') ||
                   (response.message === 'No authentication token provided') ||
                   (response.message === 'unauthorized request')) {
            alertToast.text = "Feedback server is unable to authenticate your request! Please try to log out and back in."
        } else {
            alertToast.text = "Failed to submit feedback! Please verify your input and try again."
        }

        alertToast.show()
    }
}
