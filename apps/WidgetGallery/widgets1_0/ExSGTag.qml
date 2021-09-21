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
import tech.strata.theme 1.0

Item {

    width: contentColumn.width
    height: contentColumn.height

    Column {
        id: contentColumn
        spacing: 10

        Column {

            SGWidgets.SGText {
                text: "Default"
                fontSizeMultiplier: 1.3
            }

            Row {
                spacing: 6

                SGWidgets.SGTag {
                    text: "Car"
                }

                SGWidgets.SGTag {
                    text: "Cog"
                    iconSource: "qrc:/sgimages/cog.svg"
                }
            }
        }

        Column {

            SGWidgets.SGText {
                text: "Variations"
                fontSizeMultiplier: 1.3
            }

            Row {
                spacing: 6

                SGWidgets.SGTag {
                    text: "Downloading"
                    iconSource: "qrc:/sgimages/download.svg"
                    iconColor: "black"
                    textColor: "black"
                    color: Theme.palette.orange
                }

                SGWidgets.SGTag {
                    text: "-12 dBm"
                    iconSource: "qrc:/sgimages/signal.svg"
                    font.bold: true
                    color: Theme.palette.lightGray
                }

                SGWidgets.SGTag {
                    text: "Car"
                    iconSource: "qrc:/sgimages/bookmark.svg"
                    iconColor: Theme.palette.green
                    color: Theme.palette.darkBlue
                    textColor: "white"
                    font.bold: true
                }

                SGWidgets.SGTag {
                    text: "Active"
                    font.bold: true
                    color: Theme.palette.green
                    textColor: "white"
                }
            }
        }

        Column {

            SGWidgets.SGText {
                text: "As status text"
                fontSizeMultiplier: 1.3
            }

            Column {
                spacing: 6

                SGWidgets.SGTag {
                    verticalPadding: 1
                    text: "Device cannot be configured"
                    font.bold: true
                    color: Theme.palette.red
                    textColor: "white"
                }

                SGWidgets.SGTag {
                    verticalPadding: 1
                    text: "Device cannot be configured"
                    font.bold: true
                    color: Theme.palette.orange
                    textColor: "white"
                    iconSource: "qrc:/sgimages/exclamation-triangle.svg"
                    iconColor: "white"
                }
            }
        }
    }
}
