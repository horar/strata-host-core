import QtQuick 2.12
import QtQuick.Controls 2.12

import "./common" as Common
import "./common/Colors.js" as Colors

PrtBasePage {
    title: "New Platform"

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

                        label: "Ordering Part Number"
                        helperText: "Preferred format: XXX-XXXX-XXX"
                        inputValidation: true

                        function inputValidationErrorMsg() {
                            if (text.length === 0) {
                                return "OPN is required"
                            } else if (text.length < 10) {
                                return "OPN (minimum 10 chars) is required"
                            }

                            return ""
                        }
                    }

                    Common.SgTextFieldEditor {
                        id: nameEditor
                        itemWidth: 400

                        label: "Verbose Name"
                        inputValidation: true

                        function inputValidationErrorMsg() {
                            if (text.length === 0) {
                                return "Verbose Name is required"
                            }

                            return ""
                        }
                    }

                    Common.SgTextFieldEditor {
                        id: yearEditor
                        itemWidth: 60

                        label: "Year"
                        inputValidation: true
                        validator: IntValidator {}

                        property int minYear: 1950
                        property int maxYear: 2050

                        function inputValidationErrorMsg() {
                            if (text.length === 0) {
                                return "Year is required"
                            }

                            var year = parseInt(text)
                            if (year < minYear || year > maxYear) {
                                return "Year (between " + minYear + " and " + maxYear + ") is required"
                            }

                            return ""
                        }
                    }

                    Common.SgTextFieldEditor {
                        id: originEditor
                        itemWidth: 400

                        label: "Origin"
                        inputValidation: true

                        function inputValidationErrorMsg() {
                            if (text.length === 0) {
                                return "Origin is required"
                            }

                            return ""
                        }
                    }

                    Row {
                        spacing: 16

                        Common.SgSpinBoxEditor {
                            id: boardMajorEditor
                            anchors.bottom: parent.bottom

                            label: "Board major ver."
                            inputValidation: true

                            function inputValidationErrorMsg() {
                                if (value < 1) {
                                    return "Value should be above 0"
                                }

                                return ""
                            }
                        }

                        Common.SgSpinBoxEditor {
                            id: boardMinorEditor
                            anchors.bottom: parent.bottom

                            label: "Board minor ver."
                            inputValidation: true
                        }
                    }

                    Common.SgTagSelectorEditor {
                        id: appTagEditor
                        itemWidth: 600

                        label: "Application Tags"
                        tagModel: appTagModel
                        tagColor: Colors.APPLICATION_TAG
                        inputValidation: true

                        function inputValidationErrorMsg() {
                            var tags = appTagEditor.item.getSelectedTags()
                            if (tags.length < 1) {
                                return "At least 1 application tag is required"
                            }

                            return ""
                        }
                    }

                    Common.SgTagSelectorEditor {
                        id: productTagEditor
                        itemWidth: 600

                        label: "Product Tags"
                        tagModel: producsTagModel
                        tagColor: Colors.PRODUCT_TAG
                        inputValidation: true

                        function inputValidationErrorMsg() {
                            var tags = productTagEditor.item.getSelectedTags()
                            if (tags.length < 1) {
                                return "At least 1 product tag is required"
                            }

                            return ""
                        }
                    }

                    Common.SgTextEditEditor {
                        id: descriptionEditor
                        itemWidth: 600

                        label: "Description"
                        minimumLineCount: 3
                        maximumLineCount: 10
                        inputValidation: true

                        function inputValidationErrorMsg() {
                            if (text.length === 0) {
                                return "Description is required"
                            } else if (text.length < 30 ) {
                               return "Description (minimum 30 chars) is required"
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
                            text: "Submit\nNew Platform"
                            onClicked: {
                                if (opnEditor.inputValidationErrorMsg().length === 0
                                        && nameEditor.inputValidationErrorMsg().length === 0
                                        && yearEditor.inputValidationErrorMsg().length === 0
                                        && originEditor.inputValidationErrorMsg().length === 0
                                        && boardMajorEditor.inputValidationErrorMsg().length === 0
                                        && boardMinorEditor.inputValidationErrorMsg().length === 0
                                        && appTagEditor.inputValidationErrorMsg().length === 0
                                        && productTagEditor.inputValidationErrorMsg().length === 0
                                        && descriptionEditor.inputValidationErrorMsg().length === 0)
                                {
                                    //TODO start registration process
                                    console.log("input is VALID")
                                } else {
                                    //TODO show warning dialog
                                    console.log("input is NOT VALID, plese check your data.")
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
