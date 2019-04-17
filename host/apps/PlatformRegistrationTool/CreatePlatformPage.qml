import QtQuick 2.12
import QtQuick.Controls 2.12

import "./common" as Common
import "./common/Colors.js" as Colors
import "./common/SgUtils.js" as SgUtils

PrtBasePage {
    id: page

    title: qsTr("New Platform")

    Item {
        anchors {
            fill: parent
            margins: 6
        }

        Flickable {
            id: flick
            anchors.fill: parent

            contentHeight: formWrapper.height
            contentWidth: formWrapper.width
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.VerticalFlick
            clip: true

            ScrollBar.vertical: ScrollBar {
                anchors {
                    top: flick.top
                    bottom: flick.bottom
                    right: flick.right
                    rightMargin: 1
                }

                policy: ScrollBar.AlwaysOn
                interactive: false
                width: 8
                visible: flick.height < flick.contentHeight
            }

            Item {
                id: formWrapper
                width: flick.width
                height: footer.y + footer.height

                Column {
                    id: form
                    anchors.horizontalCenter: parent.horizontalCenter

                    Common.SgTextFieldEditor {
                        id: opnEditor
                        itemWidth: 400

                        label: qsTr("Ordering Part Number")
                        helperText: qsTr("Preferred format: XXX-XXXX-XXX")
                        inputValidation: true

                        function inputValidationErrorMsg() {
                            if (text.length === 0) {
                                return qsTr("OPN is required")
                            } else if (text.length < 10) {
                                return qsTr("OPN (minimum 10 chars) is required")
                            }

                            return ""
                        }
                    }

                    Common.SgTextFieldEditor {
                        id: nameEditor
                        itemWidth: 400

                        label: qsTr("Verbose Name")
                        inputValidation: true

                        function inputValidationErrorMsg() {
                            if (text.length === 0) {
                                return qsTr("Verbose Name is required")
                            }

                            return ""
                        }
                    }

                    Common.SgTextFieldEditor {
                        id: yearEditor
                        itemWidth: 60

                        label: qsTr("Year")
                        inputValidation: true
                        validator: IntValidator {}

                        property int minYear: 1950
                        property int maxYear: 2050

                        function inputValidationErrorMsg() {
                            if (text.length === 0) {
                                return qsTr("Year is required")
                            }

                            var year = parseInt(text)
                            if (year < minYear || year > maxYear) {
                                return qsTr("Year (between %1 and %2) is required").arg(minYear).arg(maxYear)

                            }

                            return ""
                        }
                    }

                    Common.SgTextFieldEditor {
                        id: originEditor
                        itemWidth: 400

                        label: qsTr("Origin")
                        inputValidation: true

                        function inputValidationErrorMsg() {
                            if (text.length === 0) {
                                return qsTr("Origin is required")
                            }

                            return ""
                        }
                    }

                    Row {
                        spacing: 16

                        Common.SgSpinBoxEditor {
                            id: boardMajorEditor
                            anchors.bottom: parent.bottom

                            label: qsTr("Board major ver.")
                            inputValidation: true

                            function inputValidationErrorMsg() {
                                if (value < 1) {
                                    return qsTr("Board major version is required")
                                }

                                return ""
                            }
                        }

                        Common.SgSpinBoxEditor {
                            id: boardMinorEditor
                            anchors.bottom: parent.bottom

                            label: qsTr("Board minor ver.")
                            inputValidation: true
                        }
                    }

                    Common.SgTagSelectorEditor {
                        id: appTagEditor
                        itemWidth: 600

                        label: qsTr("Application Tags")
                        tagModel: appTagModel
                        tagColor: Colors.APPLICATION_TAG
                        inputValidation: true

                        function inputValidationErrorMsg() {
                            var tags = appTagEditor.item.getSelectedTags()
                            if (tags.length < 1) {
                                return qsTr("Application tag is required")
                            }

                            return ""
                        }
                    }

                    Common.SgTagSelectorEditor {
                        id: productTagEditor
                        itemWidth: 600

                        label: qsTr("Product Tags")
                        tagModel: producsTagModel
                        tagColor: Colors.PRODUCT_TAG
                        inputValidation: true

                        function inputValidationErrorMsg() {
                            var tags = productTagEditor.item.getSelectedTags()
                            if (tags.length < 1) {
                                return qsTr("Product tag is required")
                            }

                            return ""
                        }
                    }

                    Common.SgTextEditEditor {
                        id: descriptionEditor
                        itemWidth: 600

                        label: qsTr("Description")
                        minimumLineCount: 3
                        maximumLineCount: 10
                        inputValidation: true

                        function inputValidationErrorMsg() {
                            if (text.length === 0) {
                                return qsTr("Description is required")
                            } else if (text.length < 30 ) {
                               return qsTr("Description (minimum 30 chars) is required")
                            }

                            return ""
                        }
                    }
                }

                Item {
                    id: footer
                    anchors {
                        top: form.bottom
                        topMargin: 6
                    }

                    width: parent.width
                    height: buttonRow.height + 12

                    Row {
                        id: buttonRow
                        anchors.centerIn: parent

                        Common.SgButton {
                            text: qsTr("Submit\nNew Platform")
                            onClicked: {
                                var errorList = []

                                var error = opnEditor.inputValidationErrorMsg()
                                if (error.length) {
                                    errorList.push(error)
                                }

                                error = nameEditor.inputValidationErrorMsg()
                                if (error.length) {
                                    errorList.push(error)
                                }

                                error = yearEditor.inputValidationErrorMsg()
                                if (error.length) {
                                    errorList.push(error)
                                }

                                error = originEditor.inputValidationErrorMsg()
                                if (error.length) {
                                    errorList.push(error)
                                }

                                error = boardMajorEditor.inputValidationErrorMsg()
                                if (error.length) {
                                    errorList.push(error)
                                }

                                error = boardMinorEditor.inputValidationErrorMsg()
                                if (error.length) {
                                    errorList.push(error)
                                }

                                error = appTagEditor.inputValidationErrorMsg()
                                if (error.length) {
                                    errorList.push(error)
                                }

                                error = productTagEditor.inputValidationErrorMsg()
                                if (error.length) {
                                    errorList.push(error)
                                }

                                error = descriptionEditor.inputValidationErrorMsg()
                                if (error.length) {
                                    errorList.push(error)
                                }

                                if (errorList.length) {
                                    SgUtils.showMessageDialog(
                                                page,
                                                Common.SgMessageDialog.Error,
                                                "Validation Failed",
                                                errorList.join("\n"))

                                } else {
                                    //TODO start registration process
                                    console.log("input is VALID")
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    ListModel {
        id: appTagModel

        Component.onCompleted: {
            append({"value":"automotive", "selected": false})
            append({"value":"computing", "selected": false})
            append({"value":"consumer", "selected": false})
            append({"value":"industrial", "selected": false})
            append({"value":"ledlighting", "selected": false})
            append({"value":"medical", "selected": false})
            append({"value":"militaryaerospace", "selected": false})
            append({"value":"motorcontrol", "selected": false})
            append({"value":"networkingtelecom", "selected": false})
            append({"value":"powersupply", "selected": false})
            append({"value":"whitegoods", "selected": false})
            append({"value":"wirelessiot", "selected": false})
        }
    }

    ListModel {
        id: producsTagModel

        Component.onCompleted: {
            append({"value":"ac", "selected": false})
            append({"value":"analog", "selected": false})
            append({"value":"audio", "selected": false})
            append({"value":"connectivity", "selected": false})
            append({"value":"dc", "selected": false})
            append({"value":"digital", "selected": false})
            append({"value":"discrete", "selected": false})
            append({"value":"esd", "selected": false})
            append({"value":"imagesensors", "selected": false})
            append({"value":"infrared", "selected": false})
            append({"value":"led", "selected": false})
            append({"value":"mcu", "selected": false})
            append({"value":"memory", "selected": false})
            append({"value":"optoisolator", "selected": false})
            append({"value":"pm", "selected": false})
            append({"value":"sensor", "selected": false})
            append({"value":"video", "selected": false})
        }
    }
}
