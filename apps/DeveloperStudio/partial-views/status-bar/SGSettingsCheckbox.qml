import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0

RowLayout {
    id: checkboxRoot

    property alias text: text.text
    property alias checked: checkBox.checked

    CheckBox {
        id: checkBox
    }

    SGText {
        id: text
        Layout.fillWidth: true
        wrapMode: Text.Wrap
    }
}
