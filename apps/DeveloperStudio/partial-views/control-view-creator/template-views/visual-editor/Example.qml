import QtQuick 2.12
import QtQml 2.12

import tech.strata.sglayout 1.0

UIBase { // start_uibase
    columnCount: 30
    rowCount: 15

    LayoutContainer { // start_x3kdc
        id: warningContainer
        layoutInfo.uuid: "x3kdc"
        layoutInfo.columnsWide: 13
        layoutInfo.rowsTall: 3
        layoutInfo.xColumns: 16
        layoutInfo.yRows: 11
        contentItem: Warning {
            id: warning
        }
    } // end_x3kdc

    LayoutButton { // start_affdd
        id: button_affdd
        layoutInfo.uuid: "affdd"
        layoutInfo.columnsWide: 6
        layoutInfo.rowsTall: 1
        layoutInfo.xColumns: 16
        layoutInfo.yRows: 3

        onClicked: {
            console.log("Clicked")
        }
    } // end_affdd

    LayoutSGComboBox { // start_844a3
        id: sgComboBox_844a3
        layoutInfo.uuid: "844a3"
        layoutInfo.columnsWide: 6
        layoutInfo.rowsTall: 1
        layoutInfo.xColumns: 23
        layoutInfo.yRows: 3

        model: ["Amps", "Volts", "Watts"]

        onActivated: {
            console.log("onActivated:", currentIndex, currentText)
        }
    } // end_844a3

    LayoutDivider { // start_92c80
        id: divider_92c80
        layoutInfo.uuid: "92c80"
        layoutInfo.columnsWide: 28
        layoutInfo.rowsTall: 1
        layoutInfo.xColumns: 1
        layoutInfo.yRows: 2
    } // end_92c80

    LayoutSGGraph { // start_9bf31
        id: sgGraph_9bf31
        layoutInfo.uuid: "9bf31"
        layoutInfo.columnsWide: 14
        layoutInfo.rowsTall: 8
        layoutInfo.xColumns: 1
        layoutInfo.yRows: 6

        title: "Example Graph"
        xMin: 0
        xMax: 1
        yMin: 0
        yMax: 1
        xTitle: "X Axis"
        yTitle: "Y Axis"
        xGrid : true
        yGrid : true
        gridColor: "black"
    } // end_9bf31

    LayoutSGInfoBox { // start_9cb37
        id: sgInfoBox_9cb37
        layoutInfo.uuid: "9cb37"
        layoutInfo.columnsWide: 5
        layoutInfo.rowsTall: 1
        layoutInfo.xColumns: 20
        layoutInfo.yRows: 7

        text: "100"
        readOnly : true
    } // end_9cb37

    LayoutSGSlider { // start_8eeff
        id: sgSlider_8eeff
        layoutInfo.uuid: "8eeff"
        layoutInfo.columnsWide: 13
        layoutInfo.rowsTall: 1
        layoutInfo.xColumns: 16
        layoutInfo.yRows: 5

        from : 0
        to : 100
        live : false

        onUserSet : {
            console.log("onUserSet:", value)
        }
    } // end_8eeff

    LayoutText { // start_93473
        id: text_93473
        layoutInfo.uuid: "93473"
        layoutInfo.columnsWide: 14
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 1
        layoutInfo.yRows: 3
        text: "Some example description text. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin eget consectetur ipsum. Mauris quam purus, volutpat at dictum sed, porta maximus enim. In dapibus vestibulum aliquet. Morbi fermentum arcu eget ligula laoreet, a tempor sem ullamcorper. Cras iaculis massa in mollis accumsan. In arcu ligula, volutpat id lacus vel, tempor fringilla enim. Cras maximus aliquet mauris, sed fermentum ligula condimentum ut. Nunc sed malesuada dui."
    } // end_93473

    LayoutText { // start_f40df
        id: text_f40df
        layoutInfo.uuid: "f40df"
        layoutInfo.columnsWide: 28
        layoutInfo.rowsTall: 1
        layoutInfo.xColumns: 1
        layoutInfo.yRows: 1

        text: "Example View Title"
        fontSizeMode: Text.Fit
        font.pixelSize: 40
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    } // end_f40df

    LayoutText { // start_c5c74
        id: layoutText_c5c74
        layoutInfo.uuid: "c5c74"
        layoutInfo.columnsWide: 4
        layoutInfo.rowsTall: 1
        layoutInfo.xColumns: 16
        layoutInfo.yRows: 7

        text: "Input: "
        fontSizeMode: Text.Fit
        font.pixelSize: 20
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
    } // end_c5c74

    LayoutText { // start_e4a66
        id: layoutText_e4a66
        layoutInfo.uuid: "e4a66"
        layoutInfo.columnsWide: 4
        layoutInfo.rowsTall: 1
        layoutInfo.xColumns: 25
        layoutInfo.yRows: 7

        text: " Volts"
        fontSizeMode: Text.Fit
        font.pixelSize: 20
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
    } // end_e4a66

    LayoutText { // start_cb756
        id: layoutText_cb756
        layoutInfo.uuid: "cb756"
        layoutInfo.columnsWide: 4
        layoutInfo.rowsTall: 1
        layoutInfo.xColumns: 16
        layoutInfo.yRows: 9

        text: "Output: "
        fontSizeMode: Text.Fit
        font.pixelSize: 20
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
    } // end_cb756

    LayoutSGInfoBox { // start_122e0
        id: layoutSGInfoBox_122e0
        layoutInfo.uuid: "122e0"
        layoutInfo.columnsWide: 5
        layoutInfo.rowsTall: 1
        layoutInfo.xColumns: 20
        layoutInfo.yRows: 9

        text: "100"
        readOnly : true
    } // end_122e0

    LayoutText { // start_cbef6
        id: layoutText_cbef6
        layoutInfo.uuid: "cbef6"
        layoutInfo.columnsWide: 4
        layoutInfo.rowsTall: 1
        layoutInfo.xColumns: 25
        layoutInfo.yRows: 9

        text: " Volts"
        fontSizeMode: Text.Fit
        font.pixelSize: 20
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
    } // end_cbef6
} // end_uibase
