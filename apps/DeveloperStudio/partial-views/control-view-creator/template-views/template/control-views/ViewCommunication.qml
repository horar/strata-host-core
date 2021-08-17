import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQml 2.12

import tech.strata.sglayout 1.0

UIBase {
    ScrollView {
        id: rootScroll
        anchors {
            fill: parent
            margins: 7
        }

        ScrollBar.vertical: ScrollBar {
            height: rootScroll.contentHeight
            anchors.right: parent.right
        }

        TextEdit {
            id: txt
            readOnly: true
            selectByMouse: true
            anchors {
                fill: parent
            }
            text: {
                if (type === 1) {
                    JSON.stringify(my_cmd_simple_obj,null,4)
                } else if (type === 2) {
                    JSON.stringify(my_cmd_simple_periodic_text, null, 4)
                } else if (type === 3) {
                    JSON.stringify(my_cmd_simple_start_periodic_obj, null, 4)
                } 
            }
            font.pixelSize: 11
        }
    }
}
