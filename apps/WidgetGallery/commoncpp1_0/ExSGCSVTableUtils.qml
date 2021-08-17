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

            property string cmdName: "my_data_cmd"

            property var payload: {
                "dac": 0.00,
                "io": false,
                "pwm": 0
            }

            SGWidgets.SGButton {
                text: "Export to csv"
                Layout.alignment: Qt.AlignHCenter
                onClicked: {
                    sgExportCSV.headers = Object.keys(rowButton.payload)
                    sgExportCSV.cmdName = `${rowButton.cmdName}_${Date.now()}`
                    sgExportCSV.folderPath = "file:///Users/zbb69r/CSVFolder"
                    for (var i = 0; i < 100; i++) {
                        if (i % 2 === 0) {
                            rowButton.payload["io"] = true
                        } else {
                            rowButton.payload["io"] = false
                        }
                        rowButton.payload["dac"] = Math.random(i).toFixed(2)
                        rowButton.payload["pwm"] = Math.random(rowButton.payload["dac"]).toFixed(2)
                        sgExportCSV.updateTableFromControlView(rowButton.payload, true)
                    }
                }
            }
        }
    }

    CommonCpp.SGCSVTableUtils {
        id: sgExportCSV
    }

}
