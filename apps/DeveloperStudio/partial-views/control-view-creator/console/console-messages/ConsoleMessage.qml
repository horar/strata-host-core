/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0
import tech.strata.theme 1.0
import tech.strata.sgwidgets 1.0 as SGWidgets

TextEdit {
    id: msgText
    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    color: current ? "black" : "#777"
    readOnly: true
    selectByMouse: false // selection determined by dragArea
    selectionColor: Theme.palette.onsemiOrange
    persistentSelection: true
    font.pixelSize: SGWidgets.SGSettings.fontPixelSize * fontMultiplier

    property bool current: false

    onSelectedTextChanged: model.selection = selectedText
    onSelectionStartChanged: model.selectionStart = selectionStart
    onSelectionEndChanged: model.selectionEnd = selectionEnd
}
