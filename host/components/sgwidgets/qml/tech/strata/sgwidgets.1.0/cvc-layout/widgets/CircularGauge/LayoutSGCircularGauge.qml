import QtQuick 2.12
import tech.strata.sgwidgets 1.0

import "../../"

LayoutContainer {

    // pass through all properties
    property real value: 0
    property color gaugeFillColor1: "#0cf"
    property color gaugeFillColor2: "red"
    property color gaugeBackgroundColor: "#E5E5E5"
    property color centerTextColor: "black"
    property color outerTextColor: "#808080"
    property real unitTextFontSizeMultiplier: 1.0
    property real outerTextFontSizeMultiplier: 1.0
    property int valueDecimalPlaces: tickmarkDecimalPlaces
    property int tickmarkDecimalPlaces: circularGaugeObject.tickmarkDecimalPlaces

    property alias minimumValue: circularGaugeObject.minimumValue
    property alias maximumValue: circularGaugeObject.maximumValue
    property alias tickmarkStepSize : circularGaugeObject.tickmarkStepSize
    property alias unitText: circularGaugeObject.unitText

    SGCircularGauge {
        id: circularGaugeObject
        gaugeFillColor1: parent.gaugeFillColor1
        gaugeFillColor2: parent.gaugeFillColor2
        gaugeBackgroundColor: parent.gaugeBackgroundColor
        centerTextColor: parent.centerTextColor
        outerTextColor: parent.outerTextColor
        unitTextFontSizeMultiplier: parent.unitTextFontSizeMultiplier
        value : parent.value
        outerTextFontSizeMultiplier: parent.outerTextFontSizeMultiplier


    }
}

