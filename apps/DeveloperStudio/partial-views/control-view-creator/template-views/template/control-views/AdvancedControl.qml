/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQml 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.sglayout 1.0

import "qrc:/js/help_layout_manager.js" as Help

UIBase { // start_uibase
    columnCount: 40
    rowCount: 40

    Component.onCompleted: {
        Help.registerTarget(advText, "Place holder for Advanced control view help messages", 0, "AdvanceControlHelp")
    }

    LayoutText { // start_7232e
        id: advText
        layoutInfo.uuid: "7232e"
        layoutInfo.columnsWide: 38
        layoutInfo.rowsTall: 9
        layoutInfo.xColumns: 1
        layoutInfo.yRows: 1

        text: "Advanced view Control Tab or Other Supporting Tabs: \nShould be used for more detailed UI implementations such as register map tables or advanced functionality. Take the idea of walking the user into evaluating the board by ensuring the board is instantly functional when powered on and then dive into these advanced features."
        fontSizeMode: Text.Fit
        font.pixelSize: 40
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    } // end_7232e
} // end_uibase
