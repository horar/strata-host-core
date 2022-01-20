/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import tech.strata.sgwidgets 1.0
import QtQml 2.12

import "../../"

LayoutContainer {

    // pass through all properties
    property alias panXEnabled: graphObject.panXEnabled
    property alias panYEnabled: graphObject.panYEnabled
    property alias zoomXEnabled: graphObject.zoomXEnabled
    property alias zoomYEnabled: graphObject.zoomYEnabled

    //Advance feature for tooltip.
    property alias mouseArea: graphObject.mouseArea
    property alias xMin: graphObject.xMin
    property alias xMax: graphObject.xMax
    property alias yMin: graphObject.yMin
    property alias yMax: graphObject.yMax
    property alias xTitle: graphObject.xTitle
    property alias yTitle: graphObject.yTitle
    property alias title: graphObject.title
    property alias xGrid: graphObject.xGrid
    property alias yGrid: graphObject.yGrid
    property alias gridColor: graphObject.gridColor

    function createCurve(name) {
       return graphObject.createCurve(name)
    }

    function curve(index) {
       return graphObject.curve(index)
    }

    function shiftXAxis(offset) {
       return graphObject.shiftXAxis(offset)
    }

    function shiftYAxis(offset) {
       return graphObject.shiftYAxis(offset)
    }

    function removeCurve(index) {
       return graphObject.removeCurve(index)
    }

    function update() {
       return graphObject.update()
    }

    contentItem: SGGraph {
        id: graphObject
    }
}

