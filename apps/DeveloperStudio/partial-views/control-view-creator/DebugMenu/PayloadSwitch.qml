import QtQuick 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0
import tech.strata.signals 1.0

Item {
    width: parent.width
    height: row.height
    property alias name: labelText.text
    property alias value: payloadEnabled.checked

    RowLayout {
        id: row
        width: parent.width

        Item {
            Layout.preferredWidth: 10
        }

        SGText {
            id: labelText
            font.bold: true
            fontSizeMultiplier: 1.2
            Layout.preferredWidth: 100
        }

        Item {
            Layout.preferredWidth: 10
        }

        SGSwitch {
            id: payloadEnabled
            checkedLabel: "true"
            uncheckedLabel: "false"
            Layout.preferredWidth: 100
            Layout.preferredHeight: 35
        }

        Item {
            Layout.fillWidth: true
        }
    }
}
