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
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.commoncpp 1.0 as CommonCpp

ColumnLayout {
    id: exExportCsv

    Component.onCompleted: {
        csvUtil.clear()
        csvUtil.appendRow(["dac","io","rev"])
        textEdit.text += JSON.stringify(["dac","io","rev"]) + "\n"
    }

    SGWidgets.SGAlignedLabel {
        id: exportLabel
        target: column
        text: "Export CSV to file"
        fontSizeMultiplier: 2.1

        ColumnLayout {
            id: column

            SGWidgets.SGTextEdit {
                id: jsonExample
                wrapMode: Text.WordWrap
                enabled: false
                text: "\"my_cmd\": {\n"
                      + "    \"payload\": {\n"
                      + "        \"dac\": 0.7,\n"
                      + "        \"io\": true,\n"
                      + "        \"rev\": 56\n"
                      + "    }\n"
                      + "}\n"
            }

            SGWidgets.SGTextEdit {
                id: textEdit
                text: ""
                wrapMode: Text.WrapAnywhere
                enabled: false
                width: exExportCsv.width
                textFormat: TextEdit.RichText
                clip: true
                height: 50
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
                text: "Clear Data"

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
                    textEdit.text = ""
                    for (var i = 0; i < data.length; i++) {
                        textEdit.text += JSON.stringify(data[i]) + "\n"
                    }
                }
            }
        }
    }

    FileDialog {
        id: importDialog
        selectMultiple: false
        selectFolder: false

        onAccepted: {
            textEdit.text = ""
            let data = csvUtil.importFromFile(importDialog.fileUrl);
            console.info(data);
            for (let i = 0; i < data.length; i++) {
                textEdit.text += JSON.stringify(data[i]) + "\n"
            }
            close()
        }
    }

    FileDialog {
        id: exportDialog
        selectMultiple: false
        selectFolder: true

        onAccepted: {
            csvUtil.writeToFile(exportDialog.fileUrl)
            close()
        }
    }

    CommonCpp.SGCSVUtils {
        id: csvUtil
    }
}
