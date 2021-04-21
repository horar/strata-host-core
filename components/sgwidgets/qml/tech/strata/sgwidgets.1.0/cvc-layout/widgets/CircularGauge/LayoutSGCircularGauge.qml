import QtQuick 2.12
import tech.strata.sgwidgets 1.0

import "../../"

LayoutContainer {

    // pass through all properties
    property alias value: circularGaugeObject.value
    property alias gaugeFillColor1: circularGaugeObject.gaugeFillColor1
    property alias gaugeFillColor2: circularGaugeObject.gaugeFillColor2
    property alias gaugeBackgroundColor: circularGaugeObject.gaugeBackgroundColor
    property alias centerTextColor: circularGaugeObject.centerTextColor
    property alias outerTextColor: circularGaugeObject.outerTextColor
    property alias unitTextFontSizeMultiplier: circularGaugeObject.unitTextFontSizeMultiplier
    property alias outerTextFontSizeMultiplier: circularGaugeObject.outerTextFontSizeMultiplier
    property alias valueDecimalPlaces: circularGaugeObject.valueDecimalPlaces
    property alias tickmarkDecimalPlaces: circularGaugeObject.tickmarkDecimalPlaces
    property alias minimumValue: circularGaugeObject.minimumValue
    property alias maximumValue: circularGaugeObject.maximumValue
    property alias tickmarkStepSize : circularGaugeObject.tickmarkStepSize
    property alias unitText: circularGaugeObject.unitText

    contentItem: SGCircularGauge {
        id: circularGaugeObject
    }
}

