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
import tech.strata.sci 1.0 as Sci

FocusScope {
    id: validationView

    property int baseSpacing: 16
    property int innerSpacing: 8

    property QtObject platformTestModel: model.platform.platformTestModel
    property QtObject platformTestMessageModel: model.platform.platformTestMessageModel

    FocusScope {
        id: content
        anchors {
            fill: parent
            margins: baseSpacing
        }

        focus: true

        SGWidgets.SGText {
            id: title
            anchors {
                left: parent.left
            }

            text: "Validate platform"
            fontSizeMultiplier: 2.0
            font.bold: true
        }

        Column {
            id: testViewWrapper
            anchors {
                top: title.bottom
                topMargin: baseSpacing
                left: parent.left
            }

            spacing: baseSpacing

            SGWidgets.SGText {
                text: "Tests:"
                fontSizeMultiplier: 1.3
            }

            Column {
                id: testView
                spacing: innerSpacing

                Repeater {
                    model: platformTestModel

                    delegate: SGWidgets.SGCheckBox {
                        id: enabledCheckbox

                        text: model.name
                        enabled: !platformTestModel.isRunning
                        padding: 0

                        onCheckedChanged : {
                            platformTestModel.setEnabled(index, checked)
                        }

                        contentItem: Row {
                            leftPadding: enabledCheckbox.indicator && !enabledCheckbox.mirrored ? enabledCheckbox.indicator.width + enabledCheckbox.spacing : 0
                            rightPadding: enabledCheckbox.indicator && enabledCheckbox.mirrored ? enabledCheckbox.indicator.width + enabledCheckbox.spacing : 0
                            spacing: 4

                            SGWidgets.SGIcon {
                                id: testIcon
                                height: Math.floor(0.7 * enabledCheckbox.height)
                                width: height
                                anchors {
                                    verticalCenter: parent.verticalCenter
                                }

                                source: "qrc:/sgimages/exclamation-triangle.svg"
                                iconColor: Theme.palette.warning
                                visible: model.warningText.length > 0
                            }

                            SGWidgets.SGText {
                                id: testText
                                anchors {
                                    verticalCenter: parent.verticalCenter
                                }

                                text: enabledCheckbox.text
                                fontSizeMultiplier: 1.1
                            }
                        }

                        ToolTip {
                            id: tooltip
                            visible: model.warningText.length > 0 && enabledCheckbox.hovered
                            delay: 500
                            timeout: 4000
                            font.pixelSize: SGWidgets.SGSettings.fontPixelSize
                            text: model.warningText
                        }

                        Binding {
                            target: enabledCheckbox
                            property: "checked"
                            value: model.enabled
                        }
                    }
                }
            }

            SGWidgets.SGText {
                text: "Settings:"
                fontSizeMultiplier: 1.3
            }

            SGWidgets.SGFilePicker {
                width: testView.width

                contextMenuEnabled: true
                label: "Firmware data file"
                enabled: platformTestModel.isRunning === false
                selectButtonOnlyIcon: true

                filePath: platformTestModel.firmwareFilePath

                onFilePathChanged: {
                    platformTestModel.firmwareFilePath = filePath
                }

                dialogLabel: "Select Firmware Binary"
                dialogSelectExisting: true
                dialogNameFilters: ["Binary files (*.bin)","All files (*)"]
            }

            Item {
                width: 1
                height: 1
            }

            SGWidgets.SGButton {
                text: "Run tests"
                enabled: !platformTestModel.isRunning && !platformTestModel.allTestsDisabled

                onClicked: {
                    platformTestModel.runTests()
                }
            }
        }

        Item {
            id: validationListWrapper
            anchors {
                left: testViewWrapper.right
                leftMargin: innerSpacing
                right: parent.right
                top: title.bottom
                topMargin: baseSpacing
                bottom: backButton.top
                bottomMargin: baseSpacing
            }

            Rectangle {
                id: listViewBg
                anchors {
                    fill: parent
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
                    fill: listViewBg
                    margins: listViewBg.border.width + 4
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

                    height: Math.max(delegateIcon.height, delegateText.height)
                    width: validationListWrapper.width

                    SGWidgets.SGIcon {
                        id: delegateIcon
                        width: 16
                        height: width

                        source: {
                            if (model.type === Sci.SciPlatformTestMessageModel.Info) {
                                return "qrc:/sgimages/info-circle.svg"
                            }
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
                            if (model.type === Sci.SciPlatformTestMessageModel.Info) {
                                return TangoTheme.palette.skyBlue1
                            }
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
                        wrapMode: Text.Wrap
                    }
                }
            }
        }

        SGWidgets.SGButton {
            id: backButton
            anchors {
                left: parent.left
                bottom: parent.bottom
            }

            text: "Back"
            icon.source: "qrc:/sgimages/chevron-left.svg"
            enabled: platformTestModel.isRunning === false
            onClicked: {
                closeView()
            }
        }
    }

    function closeView() {
        StackView.view.pop();
    }
}
