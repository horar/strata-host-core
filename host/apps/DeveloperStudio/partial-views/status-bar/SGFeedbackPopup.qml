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
                        text: "ON Semiconductor would appreciate feedback on product usability, features, collateral, and quality of service. Please use this form to directly submit your feedback to our team."
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

                    Rectangle {
                        id: textEditContainer
                        color: "white"
                        border {
                            width: 1
                            color: "lightgrey"
                        }
                        Layout.fillHeight: true
                        Layout.fillWidth: true
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
                                enabled: !feedbackStatus.visible
                                // Text Length Limiter
                                readOnly: feedbackStatus.visible
                                KeyNavigation.tab: submitButton
                                KeyNavigation.priority: KeyNavigation.BeforeItem
                                Accessible.role: Accessible.EditableText
                                Accessible.name: "FeedbackEdit"

                                property int maximumLength: 1000
                                property string previousText: text

                                onTextChanged: {
                                    if(alertToast.visible) alertToast.hide();

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
                            }
                        }
                    }

                    Button {
                        id: submitButton
                        text: "Submit"
                        Layout.alignment: Qt.AlignHCenter
                        activeFocusOnTab: true
                        enabled: textEdit.text !== "" && feedbackTypeListView.currentIndex !== -1 && !feedbackStatus.visible

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
                            var feedbackInfo = { email: emailField.text, name: nameField.text,  comment: textEdit.text, type: feedbackTypeListView.currentItem.typeValue }
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
            }else if(result === "No Connection"){
                alertToast.color = "red"
                alertToast.text = "No Connection!"
            }else{
                alertToast.color = "red"
                alertToast.text = "Connection to feedback server failed!"
            }
            alertToast.show()
        }
    }

    function resetForm(){
        textEdit.text = ""
        feedbackTypeListView.currentIndex = -1
    }
}
