import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0
import tech.strata.theme 1.0

Item {
    id: msgRoot
    height: msgMetric.height * msgText.lineCount
    width: root.width

    property alias msg: msgText.text
    property bool current: false
    property alias msgText: msgText
    property string selection: msgText.selectedText
    property int selectionStart: msgText.selectionStart
    property int selectionEnd: msgText.selectionEnd

    SGTextEdit {
        id: msgText
        fontSizeMultiplier: fontMultiplier
        anchors.fill: parent
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        color: current ? "black" : "#777"
        readOnly: true
        selectByMouse: true
        selectionColor: Theme.palette.highlight
        contextMenuEnabled: true
        onSelectedTextChanged: msgRoot.selection = selectedText
        onSelectionStartChanged: msgRoot.selectionStart = selectionStart
        onSelectionEndChanged: msgRoot.selectionEnd = selectionEnd
    }

    TextMetrics {
        id: msgMetric
        text: msg
        font.pixelSize: SGSettings.fontPixelSize * fontMultiplier
    }
}
