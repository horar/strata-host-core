import QtQuick 2.0
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0

import 'qrc:/partial-views/login'

Item {
    Layout.columnSpan: 2
    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
    Layout.bottomMargin: parent.rowSpacing
    Layout.preferredWidth: newPasswordRow.Layout.preferredWidth

    property bool editable: false
    property alias placeHolderText: textField.placeholderText
    property alias plainText: plainText
    property alias textField: textField
    property alias validationCheck: textField.valid
    property alias showValidIcon: textField.showIcon

    onEditableChanged: {
        plainText.visible = !editable
        textField.visible = editable
    }

    SGText {
        id: plainText
        text: ""

        anchors.verticalCenter: parent.verticalCenter
        verticalAlignment: Text.AlignVCenter
        fontSizeMultiplier: 0.9
        textFormat: Text.PlainText
        visible: true
        elide: Text.ElideRight
    }

    ValidationField {
        id: textField

        text: plainText.text
        width: 250
        placeholderText: ""
        valid: text.match(/\S/)
        visible: false
    }
}
