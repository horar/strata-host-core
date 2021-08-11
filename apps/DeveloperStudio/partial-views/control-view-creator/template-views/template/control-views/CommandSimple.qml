import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQml 2.12

import tech.strata.sglayout 1.0

UIBase {
    ScrollView {
        id: root
        anchors {
            fill: parent
            margins: 7
        }
        TextEdit {
            id: txt
            readOnly: true
            selectByMouse: true
            anchors {
                fill: parent
            }
            text: JSON.stringify(my_cmd_simple_obj,null,4)
            font.pixelSize: 11
        }
        ScrollBar.vertical: ScrollBar {
            height: txt.contentHeight
            anchors.right: parent.right
        }
    }
}