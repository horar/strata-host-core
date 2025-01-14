/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.commoncpp 1.0 as CommonCpp

ColumnLayout {
    id: exExportCsv

    Component.onCompleted: {
        csvUtil.clear()
        csvUtil.appendRow(["dac","io","rev"])
        textEdit.text = JSON.stringify(["dac","io","rev"]) + "\n"
    }

    SGWidgets.SGAlignedLabel {
        id: exportLabel
        target: column
        text: "Csv utilities that allow for export and import"
        fontSizeMultiplier: 2.1

        ColumnLayout {
            id: column

            SGWidgets.SGTextEdit {
                id: jsonExample
                wrapMode: Text.WordWrap
                enabled: false
                text: "Currently stored CSV data: "
            }

            ScrollView {
                Layout.preferredWidth: exExportCsv.width
                Layout.maximumHeight: 150
                clip: true

                SGWidgets.SGTextEdit {
                    id: textEdit
                    text: ""
                    wrapMode: Text.WrapAnywhere
                    enabled: false
                    textFormat: TextEdit.RichText
                    clip: true
                }
            }

            SGWidgets.SGButton {
                text: "Append Row"

                onClicked: {
                    let data = [Math.random(1000).toFixed(2), Math.random(1000).toFixed(0) % 2 === 0, Math.random(1000).toFixed(2)]
                    csvUtil.appendRow(data)
                    textEdit.text += JSON.stringify(data) + "\n"
                }
            }

            SGWidgets.SGButton {
                text: "Clear Data and re-add headers"

                onClicked: {
                    csvUtil.clear()
                    csvUtil.appendRow(["dac","io","rev"])
                    textEdit.text = JSON.stringify(["dac","io","rev"]) + "\n"
                }
            }

            SGWidgets.SGButton {
                text: "Import from File"

                onClicked: {
                   importDialog.open()
                }
            }

            SGWidgets.SGButton {
                text: "Get Data"

                onClicked: {
                    let data = csvUtil.getData()
                    console.info(JSON.stringify(data))
                }
            }

            SGWidgets.SGButton {
                text: "Set Data"

                onClicked: {
                    let data = [["dac","io", "rev"],["1.00", true, "0.57"]]
                    csvUtil.setData(data)
                    textEdit.clear()
                    for (var i = 0; i < data.length; i++) {
                        textEdit.text += JSON.stringify(data[i]) + "\n"
                    }
                }
            }

            SGWidgets.SGButton {
                text: "Write to file"

                onClicked: {
                    exportDialog.open()
                }
            }
        }
    }

    FileDialog {
        id: importDialog
        selectFolder: false
        selectMultiple: false
        nameFilters: ["*.csv"]

        onAccepted: {
            textEdit.clear()
            let data = csvUtil.importFromFile(importDialog.fileUrl);
            console.info(JSON.stringify(data));
            for (let i = 0; i < data.length; i++) {
                textEdit.text += JSON.stringify(data[i]) + "\n"
            }
        }
    }

    FileDialog {
        id: exportDialog
        selectFolder: false
        selectExisting: false
        selectMultiple: false
        nameFilters: [ "CSV files (*.csv)" ]

        onAccepted: {
            csvUtil.writeToFile(fileUrl)
        }
    }

    CommonCpp.SGCSVUtils {
        id: csvUtil
    }
}
