import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0
import tech.strata.theme 1.0

Item {
    height: msgMetric.height * msgText.lineCount
    width: root.width

    property alias msg: msgText.text
    property alias current: msgText.enabled

    SGTextEdit {
        id: msgText
        fontSizeMultiplier: fontMultiplier
        anchors.fill: parent
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        color: current ? "black" : "#777"
        readOnly: true
        selectByMouse: true
        selectionColor: Theme.palette.highlight
    }

    TextMetrics {
        id: msgMetric
        text: msg
        font.pixelSize: SGSettings.fontPixelSize * fontMultiplier
    }
}
