import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.2
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.commoncpp 1.0 as CommonCpp

ColumnLayout {
    id: exExportCsv

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

            SGWidgets.SGButton {
                id: sgButton
                text: "Open export folder dialog"

                onClicked: {
                    fileDialog.selectMultiple = false
                    fileDialog.selectFolder = true
                    fileDialog.open()
                }
            }

            SGWidgets.SGButton {
                text: "Append to Row"

                onClicked: {
                    let data = ["1.11","false","5.33"]
                    csvUtil.appendRow(data)
                }
            }

            SGWidgets.SGButton {
                text: "Clear Data"

                onClicked: {
                    csvUtil.clear()
                }
            }

            SGWidgets.SGButton {
                text: "Import from File"

                onClicked: {
                    fileDialog.selectMultiple = false
                    fileDialog.selectFolder = false
                    fileDialog.open()
                }
            }

            SGWidgets.SGButton {
                text: "Get Data"

                onClicked: {
                    let data = csvUtil.getData()
                    console.info(data)
                }
            }

            SGWidgets.SGTextEdit {
                id: textEdit
                text: csvUtil.getData().toString()
                readOnly: true
            }
        }
    }


    FileDialog {
        id: fileDialog
        onAccepted: {
            csvUtil.outputPath = fileDialog.fileUrl
            if (!selectFolder) {
                let data = csvUtil.importFromFile(csvUtil.outputPath)
                console.info(data)
            }
            close()
        }
    }

    CommonCpp.SGCSVUtils {
        id: csvUtil
        outputPath: fileDialog.shortcuts.home
    }
}
