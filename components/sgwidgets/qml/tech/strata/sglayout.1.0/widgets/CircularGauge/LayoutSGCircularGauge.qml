/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import tech.strata.sgwidgets 1.0

import "../../"

LayoutContainer {
    id: layoutSGCircularGauge

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

    function lerpColor (color1, color2, x){
        if (Qt.colorEqual(color1, color2)){
            return color1;
        } else {
            return Qt.hsva(
                color1.hsvHue * (1 - x) + color2.hsvHue * x,
                color1.hsvSaturation * (1 - x) + color2.hsvSaturation * x,
                color1.hsvValue * (1 - x) + color2.hsvValue * x, 1
                );
        }
    }

    contentItem: SGCircularGauge {
        id: circularGaugeObject

        function lerpColor (color1, color2, x) {
            return layoutSGCircularGauge.lerpColor(color1, color2, x)
        }
    }
}

