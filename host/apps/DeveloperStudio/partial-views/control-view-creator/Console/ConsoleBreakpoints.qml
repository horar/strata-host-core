import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0


Item {
    ListView {
        anchors.fill: parent
        model: breakPointModel

        delegate: Item {
            width: parent.width
            height: 20
            RowLayout {
                anchors.fill: parent
                SGText {
                    Layout.alignment: Qt.AlignLeft
                    text: Number.toString(modeData.index)
                }

                SGText {
                    Layout.alignment: Qt.AlignHCenter
                    text: modelData.lineCode
                }

                SGText {
                    Layout.alignment: Qt.AlignRight
                    text: Number.toString(modeData.lineNumber)
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }
    }

    ListModel {
        id: breakPointModel

        function createBreakPoint(lineNumber, lineCode,){
            breakPointModel.append({lineNumber: lineNumber, lineCode: lineCode})
        }
    }
}
