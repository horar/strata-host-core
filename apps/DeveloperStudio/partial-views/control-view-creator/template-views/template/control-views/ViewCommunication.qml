import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQml 2.12

import tech.strata.sglayout 1.0

UIBase {
    property alias text: txt.text

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
            font.pixelSize: 11
        }
    }
}
