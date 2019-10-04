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
    property string versionNumber
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

        GridLayout {
            columns: 2

            Text {
                text: "Name:"
            }

            ValidationField {
                id: nameField
                valid: text !== ""
            }

            Text {
                text: "Email:"
            }

            ValidationField {
                id: emailField
                valid: text !== "" && acceptableInput && validEmail

                property bool validEmail: text.match(/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/)

                validator: RegExpValidator {
                    // regex from https://emailregex.com/
                    regExp: /^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/
                }
            }

            Text {
                text: "Company:"
            }

            ValidationField {
                id: companyField
                valid: text !== ""

                KeyNavigation.tab: textEdit
            }
        }

        Rectangle {
            id: feedbackFormContainer
            color: "#efefef"
            Layout.preferredWidth: mainColumn.width
            Layout.preferredHeight: feedbackColumn.height

            ColumnLayout {
                id: feedbackColumn
                width: feedbackFormContainer.width
                spacing: 20

                Rectangle {
                    id: feedbackFormTitle
                    color: "#ddd"
                    Layout.fillWidth: true
                    height: 35

                    Text {
                        id: feedbackFormTitleText
                        text: "Any comments or questions:"
                        font {
                            pixelSize: 15
                            family: Fonts.franklinGothicBook
                        }
                        anchors {
                            verticalCenter: feedbackFormTitle.verticalCenter
                            verticalCenterOffset: 2
                            left: feedbackFormTitle.left
                            leftMargin: 15
                        }
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
                    Layout.leftMargin: 15
                    Layout.rightMargin: 15
                    clip: true

                    ScrollView {
                        id: scrollingText
                        anchors {
                            fill: textEditContainer
                            margins: 10
                        }

                        TextEdit {
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
                    id: submitButton
                    text: "Submit"
                    Layout.bottomMargin: 20
                    Layout.alignment: Qt.AlignHCenter
                    activeFocusOnTab: true
                    enabled: textEdit.text !== "" && nameField.valid && emailField.valid && companyField.valid


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
                        var feedbackInfo = { email: emailField.text, name: nameField.text, company: companyField.text, comment: textEdit.text }

                        function success() {
                            confirmPopup.open()
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
