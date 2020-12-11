import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0

Item {
    height: msgMetric.height
    width: root.width

    property alias msg: msgText.text

    SGText {
        id: msgText
        fontSizeMultiplier: fontMultiplier
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        elide: Text.ElideRight
    }

    TextMetrics {
        id: msgMetric
        text: msg
        font.pixelSize: SGSettings.fontPixelSize * fontMultiplier
    }
}
