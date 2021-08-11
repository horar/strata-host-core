import QtQuick 2.12

import tech.strata.sglayout 1.0

UIBase { // start_uibase
    columnCount: 40
    rowCount: 40

    LayoutText { // start_7232e
        id: text_7232e
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
