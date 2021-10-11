/*
 * Copyright (c) 2018-2021 onsemi.
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

    property string filePath: ""

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
                text: "Export to Folder"

                onClicked: {
                    exportDialog.open()
                }
            }

            SGWidgets.SGButton {
                text: "Append to Row"

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

            RowLayout {
                Layout.preferredWidth: exExportCsv.width
                spacing: 0
                SGWidgets.SGButton {
                    text: "Write to file"

                    onClicked: {
                       if (exExportCsv.filePath.length > 0 && (exportName.text.length > 0 && exportName.text.endsWith(".csv"))) {
                            csvUtil.writeToFile(CommonCpp.SGUtilsCpp.joinFilePath(exExportCsv.filePath, exportName.text))
                       }
                    }
                }

                SGWidgets.SGText {
                    text: "Filename: "
                }

                SGWidgets.SGTextField {
                    id: exportName
                    Layout.preferredWidth: 250
                    placeholderText: "Write to file.csv"
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
            console.info(data);
            for (let i = 0; i < data.length; i++) {
                textEdit.text += JSON.stringify(data[i]) + "\n"
            }
        }
    }

    FileDialog {
        id: exportDialog
        selectFolder: true
        selectMultiple: false

        onAccepted: {
            exExportCsv.filePath = fileUrl
        }
    }

    CommonCpp.SGCSVUtils {
        id: csvUtil
    }
}
