/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.logger 1.0
import QtQuick.Dialogs 1.3
import tech.strata.commoncpp 1.0 as CommonCpp
import tech.strata.fonts 1.0
import tech.strata.theme 1.0
import tech.strata.platform.validation 1.0
import tech.strata.sci 1.0 as Sci

FocusScope {
    id: validationView

    property int baseSpacing: 16

    property QtObject platformTestModel: model.platform.platformTestModel
    property QtObject platformTestMessageModel: model.platform.platformTestMessageModel

    FocusScope {
        id: content
        anchors {
            fill: parent
            margins: baseSpacing
        }

        focus: true

        Connections {
            target: model.platform.platformValidation

            onValidationFinished: {
                let validationResult = success ? "succeeded" : "failed"
                textArea1.text = textArea1.text + "Validation " + validationResult + '\n'
            }

            onValidationStatus: {
                let prefix = ""
                switch (status) {
                case PlatformValidation.Info :
                    prefix = "I: "
                    break;
                case PlatformValidation.Warning :
                    prefix = "W: "
                    break;
                case PlatformValidation.Error :
                    prefix = "E: "
                    break;
                }
                textArea1.text = textArea1.text + prefix + description + '\n'
            }
        }

        Column {
            id: testViewWrapper
            anchors {
                top: parent.top
                left: parent.left
            }

            SGWidgets.SGText {
                text: "tests:"
            }

            ListView {
                id: testView

                model: platformTestModel
                width: 200
                height: 200

                delegate: Row {

                    spacing: 10

                    SGWidgets.SGCheckBox {
                        id: enabledCheckbox
                        text: ""

                        onCheckedChanged : {
                            platformTestModel.setEnabled(index, checked)
                        }

                        Binding {
                            target: enabledCheckbox
                            property: "checked"
                            value: model.enabled
                        }
                    }

                    SGWidgets.SGText {
                        text: model.name
                    }
                }
            }

            SGWidgets.SGButton {
                text: "Run tests"
                onClicked: {
                    platformTestModel.runTests()
                }
            }

        }


        Item {
            id: validationListWrapper
            anchors {
                left: testViewWrapper.right
                leftMargin: 10

            }

            width: 400
            height: 200

            Rectangle {
                id: listViewBg
                anchors {
                    fill: validationListView
                    margins: -border.width
                }
                color: "white"
                border {
                    width: 1
                    color: TangoTheme.palette.componentBorder
                }
            }


            ListView {
                id: validationListView
                anchors {

                    fill: parent
                    margins: listViewBg.border.width
                }

                model: platformTestMessageModel
                spacing: 2
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                ScrollBar.vertical: ScrollBar {
                    id: verticalScrollbar
                    anchors {
                        right: validationListView.right
                        rightMargin: 0
                    }
                    width: visible ? 8 : 0

                    policy: ScrollBar.AlwaysOn
                    minimumSize: 0.1
                    visible: validationListView.height < validationListView.contentHeight

                    Behavior on width { NumberAnimation {}}
                }

                delegate: Item {

                    height: Math.max(delegateIcon.height, delegateIcon.height)
                    width: validationListWrapper.width

                    SGWidgets.SGIcon {
                        id: delegateIcon
                        width: 16
                        height: width

                        source: {
                            if (model.type === Sci.SciPlatformTestMessageModel.Warning) {
                                return "qrc:/sgimages/exclamation-triangle.svg"
                            }
                            if (model.type === Sci.SciPlatformTestMessageModel.Error) {
                                return "qrc:/sgimages/times-circle.svg"
                            }
                            if (model.type === Sci.SciPlatformTestMessageModel.Success) {
                                return "qrc:/sgimages/check-circle.svg"
                            }

                            return ""
                        }

                        iconColor: {
                            if (model.type === Sci.SciPlatformTestMessageModel.Warning) {
                                return TangoTheme.palette.warning
                            }
                            if (model.type === Sci.SciPlatformTestMessageModel.Error) {
                                return TangoTheme.palette.error
                            }

                            if (model.type === Sci.SciPlatformTestMessageModel.Success) {
                                return TangoTheme.palette.success
                            }

                            return "black"

                        }
                    }

                    SGWidgets.SGText {
                        id: delegateText
                        anchors {
                            left: delegateIcon.right
                            leftMargin: 4
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }

                        text: model.text
                    }
                }
            }

        }


        //old stuff
        Column {
            id: validationWrapper
            anchors {
                top: testViewWrapper.bottom
                topMargin: 50
            }

            spacing: baseSpacing

            SGWidgets.SGText {
                text: "Platform Validation"
                fontSizeMultiplier: 2.0
                font.bold: true
            }

            SGWidgets.SGButton {
                text: "Run identification"
                enabled: !model.platform.platformValidation.isRunning
                onClicked: {
                    textArea1.text = ""
                    model.platform.platformValidation.runIdentification()
                }
            }

            SGWidgets.SGTextArea {
                id: textArea1
                focus: false
                width: 600
                height: 200
                readOnly: true
            }
        }

        SGWidgets.SGButton {
            anchors {
                left: parent.left
                bottom: parent.bottom
            }

            text: "Back"
            icon.source: "qrc:/sgimages/chevron-left.svg"
            onClicked: {
                closeView()
            }
        }
    }

    function closeView() {
        StackView.view.pop();
    }
}
