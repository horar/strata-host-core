import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0

Item {
    width: timeMetrics.width
    height:timeMetrics.height

    property alias time: msgTime.text
    property alias current: msgTime.enabled

    SGText {
        id: msgTime
        fontSizeMultiplier: fontMultiplier
        width: timeMetrics.width
        height: timeMetrics.height
        color: current ? "black" : "#777"
    }

    TextMetrics {
        id: timeMetrics
        text: "24:59:59.999"
        font.pixelSize: SGSettings.fontPixelSize * fontMultiplier
    }
}
// 24:59:59.999
//
