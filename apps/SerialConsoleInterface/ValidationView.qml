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

FocusScope {
    id: validationView

    property int baseSpacing: 16

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
            id: validationWrapper
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
                    model.platform.platformValidation.runIdentification()
                }
            }

            SGWidgets.SGTextArea {
                id: textArea1
                focus: false
                width: 600
                height: 400
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
