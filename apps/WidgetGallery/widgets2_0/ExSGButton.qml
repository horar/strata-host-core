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
import tech.strata.sgwidgets 2.0
import tech.strata.logger 1.0
import tech.strata.theme 1.0


Item {

    width: contentGrid.width
    height: editEnabledCheckBox.y + editEnabledCheckBox.height

    Grid {
        id: contentGrid
        spacing: 10
        enabled: editEnabledCheckBox.checked
        columns: 2

        SGButton {
            text: "Tiny Button"
            buttonSize: SGButton.Tiny
        }

        SGButton {
            text: "Tiny Button"
            buttonSize: SGButton.Tiny
            isSecondary: true
        }

        SGButton {
            text: "Small Button"
            buttonSize: SGButton.Small
        }

        SGButton {
            text: "Small Button"
            buttonSize: SGButton.Small
            isSecondary: true
        }

        SGButton {
            text: "Medium Button"
            buttonSize: SGButton.Medium
        }

        SGButton {
            text: "Medium Button"
            buttonSize: SGButton.Medium
            isSecondary: true
        }

        SGButton {
            text: "Large Button"
            buttonSize: SGButton.Large
        }

        SGButton {
            text: "Large Button"
            buttonSize: SGButton.Large
            isSecondary: true
        }

        SGButton {
            text: "Tiny Button"
            buttonSize: SGButton.Tiny
            icon.source: "qrc:/sgimages/folder-open.svg"
        }

        SGButton {
            text: "Tiny Button"
            buttonSize: SGButton.Tiny
            isSecondary: true
            icon.source: "qrc:/sgimages/folder-open.svg"
        }

        SGButton {
            text: "Small Button"
            buttonSize: SGButton.Small
            icon.source: "qrc:/sgimages/folder-open.svg"
        }

        SGButton {
            text: "Small Button"
            buttonSize: SGButton.Small
            isSecondary: true
            icon.source: "qrc:/sgimages/folder-open.svg"
        }

        SGButton {
            text: "Medium Button"
            buttonSize: SGButton.Medium
            icon.source: "qrc:/sgimages/folder-open.svg"
        }

        SGButton {
            text: "Medium Button"
            buttonSize: SGButton.Medium
            isSecondary: true
            icon.source: "qrc:/sgimages/folder-open.svg"
        }

        SGButton {
            text: "Large Button"
            buttonSize: SGButton.Large
            icon.source: "qrc:/sgimages/folder-open.svg"
        }

        SGButton {
            text: "Large Button"
            buttonSize: SGButton.Large
            isSecondary: true
            icon.source: "qrc:/sgimages/folder-open.svg"
        }

        SGButton {
            buttonSize: SGButton.Tiny
            icon.source: "qrc:/sgimages/folder-open.svg"
        }

        SGButton {
            buttonSize: SGButton.Tiny
            isSecondary: true
            icon.source: "qrc:/sgimages/folder-open.svg"
        }

        SGButton {
            buttonSize: SGButton.Small
            icon.source: "qrc:/sgimages/folder-open.svg"
        }

        SGButton {
            buttonSize: SGButton.Small
            isSecondary: true
            icon.source: "qrc:/sgimages/folder-open.svg"
        }

        SGButton {
            buttonSize: SGButton.Medium
            icon.source: "qrc:/sgimages/folder-open.svg"
        }

        SGButton {
            buttonSize: SGButton.Medium
            isSecondary: true
            icon.source: "qrc:/sgimages/folder-open.svg"
        }

        SGButton {
            buttonSize: SGButton.Large
            icon.source: "qrc:/sgimages/folder-open.svg"
        }

        SGButton {
            buttonSize: SGButton.Large
            isSecondary: true
            icon.source: "qrc:/sgimages/folder-open.svg"
        }
    }

    SGCheckBox {
        id: editEnabledCheckBox
        anchors {
            top: contentGrid.bottom
            topMargin: 20
        }

        text: "Everything enabled"
        checked: true
    }
}
