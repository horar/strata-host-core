import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0
ScrollView {
    width: parent.width
    height: parent.height
    clip: true
    ListView {
        id: consoleLogs
        anchors.fill: parent
        model: consoleItems
        delegate: Rectangle {
            width: parent.width
            height: row.height
            color: "#eee"
            anchors.leftMargin: 10
            RowLayout {
                id: row
                SGText {
                    text: model.time
                    fontSizeMultiplier: 1.3
                }

                SGText {
                    color: switch(model.type){
                           case "error":
                               return "red"
                            case "warning":
                                return "yellow"
                            case "debug":
                                return "cyan"
                            case "info":
                                return "green"
                           }
                    text: `[  ${model.type}  ]`
                    fontSizeMultiplier: 1.3
                }

                SGText {
                    text: model.msg
                    fontSizeMultiplier: 1.3
                }

            }
        }
    }

    ListModel {
        id: consoleItems
    }

    Connections {
        target: sdsModel
    }
}
