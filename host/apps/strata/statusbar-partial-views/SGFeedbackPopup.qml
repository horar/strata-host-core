import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Fonts 1.0
import QtGraphicalEffects 1.0
import "../js/feedback.js" as Feedback
import "../js/navigation_control.js" as NavigationControl

import Strata.Logger 1.0

Popup {
    id: root
    width: container.width * 0.8
    height: container.parent.windowHeight * 0.8
    modal: true
    focus: true
    padding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    function isEmailAddress(str) {
       var pattern = /\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/;
       return pattern.test(str);  // returns a boolean
    }

    DropShadow {
        width: root.width
        height: root.height
        horizontalOffset: 1
        verticalOffset: 3
        radius: 15.0
        samples: 30
        color: "#cc000000"
        source: root.background
        z: -1
        cached: true
    }

    Item {
        id: popupContainer
        width: root.width
        height: root.height
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
                id: popupTitle
                anchors {
                    left: title.left
                    leftMargin: 10
                    verticalCenter: title.verticalCenter
                }
                text: "Feedback"
                font {
                    family: Fonts.franklinGothicBold
                }
                color: "black"
            }

            Text {
                id: closer
                text: "\ue805"
                color: closeHover.containsMouse ? "#eee" : "white"
                font {
                    family: Fonts.sgicons
                    pixelSize: 20
                }
                anchors {
                    right: title.right
                    verticalCenter: title.verticalCenter
                    rightMargin: 10
                }

                MouseArea {
                    id: closeHover
                    anchors {
                        fill: closer
                    }
                    onClicked: root.close()
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }

        ScrollView {
            id: scrollView
            anchors {
                top: title.bottom
                left: popupContainer.left
                right: popupContainer.right
                bottom: popupContainer.bottom
            }

            contentHeight: contentContainer.height
            contentWidth: contentContainer.width
            clip: true

            Item {
                id: contentContainer
                width: Math.max(popupContainer.width, 600)
                height: mainColumn.height + mainColumn.anchors.margins*2
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
                        id: feedbackTextContainer
                        color: "#efefef"
                        width: mainColumn.width
                        height: feedbackTextColumn.height + feedbackTextColumn.anchors.topMargin * 2
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
                                text: "ON Semiconductor would appreciate feedback on product usability, features, collateral, and quality of service. Please use this form to directly submit your feedback to our Strata development team."
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
                                    text: "Strata Development Team"
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
                        width: mainColumn.width
                        height: feedbackFormTitle.height + feedbackColumn.height + feedbackColumn.anchors.topMargin * 2

                        Rectangle {
                            id: feedbackFormTitle
                            color: "#ddd"
                            width: feedbackFormContainer.width
                            height: 35

                            Text {
                                id: feedbackFormTitleText
                                text: "Feedback Form:"
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

                        Column {
                            id: feedbackColumn
                            anchors {
                                top: feedbackFormTitle.bottom
                                topMargin: 15
                                horizontalCenter: feedbackFormContainer.horizontalCenter
                            }
                            width: feedbackFormContainer.width-30
                            spacing: 10

                            Column {
                                id: subcolumn2
                                spacing: 10

                                SGSubmitInfoBox {
                                    id: nameBox
                                    label: "Name:"
                                    showButton: false
                                    overrideLabelWidth: 100
                                    infoBoxWidth: 200
                                    KeyNavigation.tab: emailBox.textInput
                                    KeyNavigation.priority: KeyNavigation.BeforeItem
                                }

                                SGSubmitInfoBox {
                                    id: emailBox
                                    label: "Email Address:"
                                    showButton: false
                                    overrideLabelWidth: 100
                                    infoBoxWidth: 200
                                    KeyNavigation.tab: companyBox.textInput
                                    KeyNavigation.priority: KeyNavigation.BeforeItem
                                }

                                SGSubmitInfoBox {
                                    id: companyBox
                                    label: "Company:"
                                    showButton: false
                                    overrideLabelWidth: 100
                                    infoBoxWidth: 200
                                    KeyNavigation.tab: textEdit
                                    KeyNavigation.priority: KeyNavigation.BeforeItem
                                }
                            }

                            Item {
                                id: spacer
                                width: 10
                                height: 10
                            }

                            Text {
                                id: commentLabel
                                text: "Any comments or questions:"
                            }

                            Rectangle {
                                id: textEditContainer
                                color: "white"
                                border {
                                    width: 1
                                    color: "lightgrey"
                                }
                                width: feedbackColumn.width
                                height: Math.max(scrollView.height - feedbackTextContainer.height - feedbackFormTitle.height - subcolumn2.height - 130 - submitButton.height - spacer.height - commentLabel.height, 200)

                                TextEdit {
                                    id: textEdit
                                    anchors {
                                        fill: textEditContainer
                                        margins: 10
                                    }
                                    wrapMode: TextEdit.Wrap
                                    clip: true

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

                            Button {
                                id: submitButton
                                text: "Submit"
                                onClicked: {

                                    console.log(Logger.devStudioFeedbackCategory, "in connection",textEdit.text)
                                    if(nameBox.textInput.text === "" || emailBox.textInput.text === "" || companyBox.textInput.text === ""  || textEdit.text === ""  ) {
                                        errorPopup.popupText = "All the required fields need to be completed to submit"
                                        errorPopup.open()
                                        console.log(Logger.devStudioFeedbackCategory, "error!! empty")
                                    }
                                    else if (isEmailAddress(emailBox.textInput.text) === false){
                                        console.log(Logger.devStudioFeedbackCategory, "invalid email address")
                                        invalidEmailPopup.open()
                                    }

                                    else  {
                                        var feedbackInfo = { name: nameBox.textInput.text , email : emailBox.textInput.text , company : companyBox.textInput.text, comment : textEdit.text }
                                        function success() {
                                            confirmPopup.open()
                                        }
                                        function error() {
                                             errorPopup.popupText = "Something went wrong please try again"
                                             errorPopup.open()
                                        }

                                        Feedback.feedbackInfo(feedbackInfo,success, error)

                                    }
                                }
                            }
                        }
                    }
                }
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
                nameBox.textInput.text = ""
                emailBox.textInput.text = ""
                companyBox.textInput.text = ""
            }
        }
    }
    SGConfirmationPopup {
        id: errorPopup
        cancelButtonText: ""
        titleText: "Error"
        popupText: "All the required fields need to be completed to submit"
        Connections {
            target: errorPopup.acceptButton
            onClicked: {
                //root.close()
                errorPopup.close()
            }
        }
    }
    SGConfirmationPopup {
        id: invalidEmailPopup
        cancelButtonText: ""
        titleText: "Error"
        popupText: "Invalid Email Id. Please try again"
        Connections {
            target: invalidEmailPopup.acceptButton
            onClicked: {
                //root.close()
                invalidEmailPopup.close()
            }
        }
    }
}
