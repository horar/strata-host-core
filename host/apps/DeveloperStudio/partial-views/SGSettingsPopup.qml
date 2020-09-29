import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0
SGStrataPopup {
    id: root
    modal: true
    visible: false
    headerText: "General Settings"
    closePolicy: Popup.CloseOnEscape
    focus: true
    horizontalPadding: 20
    bottomPadding: 20

    height: parent.height/2
    width: parent.width/2
    x: parent.width/2 - root.width/2
    y: parent.height/2 - root.height/2

    ColumnLayout {
        id: column
        ColumnLayout {
            Layout.alignment: Qt.AlignLeft
            SGText {
                text: "Platform View Settings"
                fontSizeMultiplier: 1.3
            }
            SGCheckBox{
                text: "open platform view automatically"
                leftPadding: 0
            }
            SGCheckBox {
                text: "Switch to active tab"
                leftPadding: 0
            }
        }
        ColumnLayout{
            Layout.alignment: Qt.AlignLeft
            SGText {
                text: "Firmware Settings"
                fontSizeMultiplier: 1.3
            }
            SGCheckBox {
                text: "Notify me when firmware version updates"
                leftPadding: 0
            }
            SGCheckBox {
                text: "Preload firmware versions"
                leftPadding: 0
                enabled: false
            }
        }
    }
}
