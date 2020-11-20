import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0

ScrollView {
    width: parent.width
    height: parent.height
    clip: true

    property double fontMultiplier: 1.3

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
                    fontSizeMultiplier: fontMultiplier
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
                    fontSizeMultiplier: fontMultiplier
                }

                SGText {
                    text: model.msg
                    fontSizeMultiplier: fontMultiplier
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
