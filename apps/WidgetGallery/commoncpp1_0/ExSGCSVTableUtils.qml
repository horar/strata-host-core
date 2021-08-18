import QtQuick 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.commoncpp 1.0 as CommonCpp

ColumnLayout {
    id: exExportCsv

    SGWidgets.SGAlignedLabel {
        target: rowButton
        text: "Basic SGExportCSV with button"
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
                text: "Export to csv"
                Layout.alignment: Qt.AlignHCenter
                onClicked: {
                    for (var i = 0; i < 100; i++) {
                        if (i % 2 === 0) {
                            rowButton.cmdObj["payload"]["io"] = true
                        } else {
                            rowButton.cmdObj["payload"]["io"] = false
                        }
                        rowButton.cmdObj["payload"]["dac"] = Math.random(i).toFixed(2)
                        rowButton.cmdObj["payload"]["pwm"] = Math.random(rowButton.cmdObj["payload"]["dac"]).toFixed(2)
                        sgExportCSV.updateTableFromControlView(rowButton.cmdObj, true)
                    }
                }
            }
        }
    }

    CommonCpp.SGCSVTableUtils {
        id: sgExportCSV
        folderPath: "file:///Users/zbb69r/CSVFolder"
    }

}
