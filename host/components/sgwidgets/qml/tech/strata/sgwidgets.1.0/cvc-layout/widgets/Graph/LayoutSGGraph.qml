import QtQuick 2.12
import tech.strata.sgwidgets 1.0

import "../../"

LayoutContainer {

    // pass through all properties
    property bool panXEnabled: true
    property bool panYEnabled: true
    property bool zoomXEnabled: true
    property bool zoomYEnabled: true
    property real fontSizeMultiplier: 1.0
    property alias mouseArea: circularGaugeObject.mouseArea
    property alias xMin: circularGaugeObject.xMin
    property alias xMax: circularGaugeObject.xMax
    property alias yMin: circularGaugeObject.yMin
    property alias yMax: circularGaugeObject.yMax
    property alias xTitle: circularGaugeObject.xTitle
    property alias yTitle: circularGaugeObject.yTitle
    property alias title: circularGaugeObject.title


    SGGraph {
        id: circularGaugeObject
        panXEnabled: panXEnabled
        panYEnabled : panYEnabled
        zoomXEnabled : zoomXEnabled
        zoomYEnabled : zoomYEnabled


    }
}

