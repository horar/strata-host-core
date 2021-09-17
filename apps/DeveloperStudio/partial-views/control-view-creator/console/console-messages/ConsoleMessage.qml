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
    selectionColor: Theme.palette.highlight
    persistentSelection: true
    font.pixelSize: SGWidgets.SGSettings.fontPixelSize * fontMultiplier

    property bool current: false

    onSelectedTextChanged: model.selection = selectedText
    onSelectionStartChanged: model.selectionStart = selectionStart
    onSelectionEndChanged: model.selectionEnd = selectionEnd
}