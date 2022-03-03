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
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0

ColumnLayout {
    id: exSgIcon

    SGAlignedLabel {
        target: toolRow
        text: "Basic SGIcon example"
        fontSizeMultiplier: 1.3

        RowLayout {
            id: toolRow
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 10
            
            SGIcon {
                id: exIcon
                source: "qrc:/sgimages/exclamation-circle.svg"
                Layout.preferredWidth: 30
                Layout.preferredHeight: Layout.preferredWidth
            }

            SGButton {
                id: colorButton
                Layout.alignment: Qt.AlignHCenter
                text: "Randomize Color"

                onClicked: {
                    exIcon.iconColor = randomColor()
                }
            }

            SGButton {
                id: defaultButton
                Layout.alignment: Qt.AlignHCenter
                text: "Restore Default Color"

                onClicked: {
                    exIcon.iconColor = "transparent"
                }
            }
        }
    }

    SGText {
        text: "(Note): The SGWidgets library contains a number of SVG icon files that you can use. If you have imported SGWidgets 1.0, which is a pre-cursor for SGIcon use, you can set these icons in your SGIcon like so: source: \"qrc:/sgimages/<icon filename here>.svg\" - each filename is shown below the icon in the following grid."
        fontSizeMultiplier: 1.1
        Layout.maximumWidth: flickWrapper.width
        wrapMode: Text.WordWrap
    }

    SGAlignedLabel {
        target: basicIconGrid
        text: "SGIcons"
        fontSizeMultiplier: 1.3

        GridLayout {
            id: basicIconGrid
            width: flickWrapper.width
            rowSpacing: 1
            columnSpacing: 1
            columns: {
                let columnCount = width / longestTextWidth.boundingRect.width
                return columnCount
            }

            Repeater {
                id: repeater
                model: iconModel

                delegate: ColumnLayout {
                    id: basicDelegate
                    width: longestTextWidth.boundingRect.width

                    SGIcon {
                        id: icon
                        source: model.source
                        width: basicDelegate.width
                        height: 21
                        iconColor: model.color
                        Layout.alignment: Qt.AlignHCenter
                    }

                    SGText {
                        text: model.name
                        width: basicDelegate.width
                        Layout.alignment: Qt.AlignHCenter
                        fontSizeMultiplier: 1.1
                    }
                }
            }
        }
    }

    Item {
        Layout.preferredHeight: 10
        Layout.fillWidth: true
    }

    ListModel {
        id: iconModel

        Component.onCompleted: {
            // list of svg icons that are located in SGWidgets
            let arr = SGUtilsCpp.getQrcPaths(":sgimages")

            for (let i = 0; i < arr.length; i++) {
                if(arr[i].includes(".svg") && !arr[i].includes("status-light")){
                    const iconObj = {
                        "name": arr[i].substring(arr[i].lastIndexOf("/") + 1,arr[i].lastIndexOf(".svg")),
                        "source": `qrc${arr[i]}`,
                        "color": "transparent",
                    }

                    append(iconObj)
                }
            }
        }
    }

    TextMetrics {
        id: longestTextWidth
        text: "exclamation-triangle"
        font.pixelSize: 13 * 1.1
    }

    function randomColor() {
        return Qt.rgba(Math.random(),Math.random(),Math.random(),1).toString()
    }
}
