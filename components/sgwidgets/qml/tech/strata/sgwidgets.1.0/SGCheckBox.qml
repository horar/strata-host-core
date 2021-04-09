import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets

CheckBox {
    id: control
    text: qsTr("CheckBox")

    contentItem: SGWidgets.SGText {
        text: control.text
        opacity: enabled ? 1.0 : 0.3
        verticalAlignment: Text.AlignVCenter
        leftPadding: control.indicator.width + control.spacing
        fontSizeMultiplier: 1.1
    }
}
