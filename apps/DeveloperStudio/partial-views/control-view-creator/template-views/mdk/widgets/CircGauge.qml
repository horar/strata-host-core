import QtQuick 2.12
import tech.strata.sgwidgets 1.0

// custom implementation of SGCircularGauge that includes some title text under it

SGCircularGauge {
    id: circGauge
    property alias text: text.text
    property alias pixelSize: text.font.pixelSize

    SGText {
        id: text
        font.pixelSize: Math.min(parent.height *.085, parent.width *.085)
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        parent: circGauge.gaugeObject
        width: parent.width
        wrapMode: Text.Wrap

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.bottom
            topMargin: parent.height * .07
        }
    }
}
