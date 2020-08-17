import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0

SGText {
    text: ""
    color: "grey"

    Layout.columnSpan: 1
    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
    Layout.bottomMargin: parent.rowSpacing
    Layout.minimumWidth: 250
}
