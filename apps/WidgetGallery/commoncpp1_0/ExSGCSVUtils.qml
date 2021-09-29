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
                    fileDialog.selectMultiple = false
                    fileDialog.selectFolder = false
                    fileDialog.open()
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

            SGWidgets.SGButton {
                text: "Write to File"

                onClicked: {
                    csvUtil.writeToFile()
                }
            }
        }
    }


    FileDialog {
        id: fileDialog
        onAccepted: {
            if (!selectFolder) {
                textEdit.text = ""
                let data = csvUtil.importFromFile(fileDialog.fileUrl);
                console.info(data);
                for (let i = 0; i < data.length; i++) {
                    textEdit.text += JSON.stringify(data[i]) + "\n"
                }
                fileDialog.selectMultiple = false
                fileDialog.selectFolder = true
            } else {
                csvUtil.outputPath = fileDialog.fileUrl
            }

            close()
        }
    }

    CommonCpp.SGCSVUtils {
        id: csvUtil
        outputPath: fileDialog.shortcuts.home
    }
}
