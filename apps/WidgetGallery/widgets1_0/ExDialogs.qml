/*
 * Copyright (c) 2018-2021 onsemi.
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

Item {

    width: contentColumn.width
    height: contentColumn.height

    property variant colorList: [confirmationInfoButton.implicitColor.toString() , "orange", "magenta"]

    Column {
        id: contentColumn
        spacing: 10

        Column {
            spacing: 10

            SGWidgets.SGText {
                text: "Message Dialogs"
                fontSizeMultiplier: 1.3
            }

            SGWidgets.SGButton {
                text: "Simple"
                onClicked: {
                    SGWidgets.SGDialogJS.showMessageDialog(
                                root,
                                SGWidgets.SGMessageDialog.Info,
                                "Button color change",
                                "You can change color by clicking on some of the buttons")
                }
            }

            SGWidgets.SGButton {
                text: "with standart buttons"
                color: colorList[colorIndex]

                property int colorIndex: 0

                onClicked: {
                    SGWidgets.SGDialogJS.showMessageDialog(
                                root,
                                SGWidgets.SGMessageDialog.Warning,
                                "Button color change",
                                "Do you want to change button color?",
                                Dialog.Yes | Dialog.No,
                                function () {
                                    console.info(Logger.wgCategory,"color change accepted")
                                    var current = colorIndex + 1
                                    colorIndex = current % colorList.length
                                },
                                function () {
                                    console.info(Logger.wgCategory,"color change rejected")
                                })
                }
            }
        }

        Column {
            spacing: 10

            SGWidgets.SGText {
                text: "Confirmation Dialogs"
                fontSizeMultiplier: 1.3
            }

            SGWidgets.SGButton {
                id: confirmationInfoButton
                text: "Info"
                color: colorList[colorIndex]

                property int colorIndex: 0

                onClicked: {
                    SGWidgets.SGDialogJS.showConfirmationDialog(
                                root,
                                "Button color change",
                                "Do you want to change button color?",
                                "Change color",
                                function () {
                                    console.info(Logger.wgCategory,"color change accepted")
                                    var current = colorIndex + 1
                                    colorIndex = current % colorList.length
                                },
                                "Keep current color",
                                function () {
                                    console.info(Logger.wgCategory,"color change rejected")
                                }
                                )
                }
            }

            SGWidgets.SGButton {
                text: "Warning"
                color: colorList[colorIndex]

                property int colorIndex: 0

                onClicked: {
                    SGWidgets.SGDialogJS.showConfirmationDialog(
                                root,
                                "Button color change",
                                "Do you want to change button color?",
                                "Change color",
                                function () {
                                    console.info(Logger.wgCategory,"color change accepted")
                                    var current = colorIndex + 1
                                    colorIndex = current % colorList.length
                                },
                                "Keep current color",
                                function () {
                                    console.info(Logger.wgCategory,"color change rejected")
                                },
                                SGWidgets.SGMessageDialog.Warning
                                )
                }
            }

            SGWidgets.SGButton {
                text: "Error"
                color: colorList[colorIndex]

                property int colorIndex: 0

                onClicked: {
                    SGWidgets.SGDialogJS.showConfirmationDialog(
                                root,
                                "Button color change",
                                "Do you want to change button color?",
                                "Change color",
                                function () {
                                    console.info(Logger.wgCategory,"color change accepted")
                                    var current = colorIndex + 1
                                    colorIndex = current % colorList.length
                                },
                                "Keep current color",
                                function () {
                                    console.info(Logger.wgCategory,"color change rejected")
                                },
                                SGWidgets.SGMessageDialog.Error
                                )
                }
            }
        }
    }
}
