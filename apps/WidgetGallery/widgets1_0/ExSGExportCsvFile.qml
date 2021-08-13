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

            property string cmdName: "my_data_cmd"

            property var payload: {
                "dac": 0.00,
                "io": false,
                "pwm": 0
            }

            SGWidgets.SGButton {
                text: "Open and populate export popup"
                Layout.alignment: Qt.AlignHCenter
                onClicked: {
                    sgExportCsv.cmdName = rowButton.cmdName
                    sgExportCsv.headers = Object.keys(rowButton.payload)
                    for (var i = 0; i < 100; i++) {
                        if (i % 2 === 0) {
                            rowButton.payload["io"] = true
                        } else {
                            rowButton.payload["io"] = false
                        }
                        rowButton.payload["dac"] = Math.random(i).toFixed(2)
                        rowButton.payload["pwm"] = Math.random(rowButton.payload["dac"]).toFixed(2)
                        sgExportCsv.updateMap("io", rowButton.payload["io"])
                        sgExportCsv.updateMap("dac", rowButton.payload["dac"])
                        sgExportCsv.updateMap("pwm", rowButton.payload["pwm"])
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
