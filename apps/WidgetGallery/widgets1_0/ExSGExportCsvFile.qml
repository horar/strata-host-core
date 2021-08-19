import QtQuick 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0 as SGWidgets

ColumnLayout {
    id: exExportCsv

    SGWidgets.SGAlignedLabel {
        target: rowButton
        text: "Basic SGExport Csv example with table preview"
        fontSizeMultiplier: 1.3

        RowLayout {
            id: rowButton
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter

            property var cmdObj: {
                "cmd": "my_data_cmd",
                "payload": {
                    "dac": 0.00,
                    "io": false,
                    "pwm": 0
                }
            }

            property var notifObj: {
                "value": "my_data_notif",
                "payload": {
                    "dac": 0.00,
                    "io": false,
                    "pwm": 0
                }
            }

            SGWidgets.SGButton {
                text: "Open and populate export popup"
                Layout.alignment: Qt.AlignHCenter
                onClicked: {
                    sgExportCsv.folderPath = "file:///Users/zbb69r/CSVFolder"
                    for (var i = 0; i < 100; i++) {
                        if (i % 2 === 0) {
                            rowButton.cmdObj["payload"]["io"] = true
                        } else {
                            rowButton.cmdObj["payload"]["io"] = false
                        }
                        rowButton.cmdObj["payload"]["dac"] = Math.random(i).toFixed(2)
                        rowButton.cmdObj["payload"]["pwm"] = Math.random(rowButton.cmdObj["payload"]["dac"]).toFixed(2)
                        sgExportCsv.updateTableFromView(rowButton.cmdObj)
                    }

                    sgExportCsv.open()
                }
            }
        }
    }


    SGWidgets.SGExportCsvFile {
        id: sgExportCsv
    }
}
