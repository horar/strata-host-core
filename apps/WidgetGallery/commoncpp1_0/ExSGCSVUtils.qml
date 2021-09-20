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
                text: "Open File Dialog"

                onClicked: {
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
                    let data = csvUtil.importFromFile(fileDialog.fileUrl)
                    console.info(data)
                }
            }

            SGWidgets.SGButton {
                text: "Get Data"

                onClicked: {
                    let data = csvUtil.getData()
                    console.info(data)
                }
            }
        }
    }


    FileDialog {
        id: fileDialog
        selectMultiple: false
        selectFolder: true
        onAccepted: {
            csvUtil.outputPath = fileDialog.fileUrl
            close()
        }
    }

    CommonCpp.SGCSVUtils {
        id: csvUtil
        outputPath: fileDialog.shortcuts.home
    }
}
