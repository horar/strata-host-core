import QtQuick 2.12

import tech.strata.sglayout 1.0

UIBase { // start_uibase
    columnCount: 20
    rowCount: 3

    property alias color: warning_background.color

    LayoutRectangle { // start_d9502
        id: warning_background
        layoutInfo.uuid: "d9502"
        layoutInfo.columnsWide: 20
        layoutInfo.rowsTall: 3
        layoutInfo.xColumns: 0
        layoutInfo.yRows: 0
        color: "#fc0007"
    } // end_d9502

    LayoutText { // start_xcvxb
        id: text_warning
        layoutInfo.uuid: "xcvxb"
        layoutInfo.columnsWide: 14
        layoutInfo.rowsTall: 1
        layoutInfo.xColumns: 3
        layoutInfo.yRows: 1
        color: "white"
        fontSizeMode: Text.Fit
        font.pixelSize: 400
        text: "Example of a widget created in Visual Editor"
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    } // end_xcvxb

    LayoutSGIcon { // start_4aacb
        id: warning_icon1
        layoutInfo.uuid: "4aacb"
        layoutInfo.columnsWide: 1
        layoutInfo.rowsTall: 1
        layoutInfo.xColumns: 1
        layoutInfo.yRows: 1
        iconColor: "white"
        source: "qrc:/sgimages/exclamation-circle.svg"
    } // end_4aacb

    LayoutSGIcon { // start_57836
        id: warning_icon2
        layoutInfo.uuid: "57836"
        layoutInfo.columnsWide: 1
        layoutInfo.rowsTall: 1
        layoutInfo.xColumns: 18
        layoutInfo.yRows: 1
        iconColor: "white"
        source: "qrc:/sgimages/exclamation-circle.svg"
    } // end_57836
} // end_uibase
