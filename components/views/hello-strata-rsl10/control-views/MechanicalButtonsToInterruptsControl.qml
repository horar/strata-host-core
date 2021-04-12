import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import "qrc:/js/help_layout_manager.js" as Help
import tech.strata.sgwidgets 1.0

CustomControl {
    id: root
    title: qsTr("Button to Interrupt")

    property real lightSizeValue: 25*factor

    // notification
    property var sw1: platformInterface.int_button1

    Component.onCompleted: {
        if (hideHeader) {
            Help.registerTarget(buttons, "Indicates rising or falling edges on the INT_ISR pin. A positive edge will turn on the indicator and a falling edge will turn off.", 0, "helloStrata_ButtonsInterrupts_Help")
        }
    }

    onSw1Changed: {
        led1.status = sw1.value ? SGStatusLight.Green : SGStatusLight.Off
    }

    contentItem: ColumnLayout {
        id: content
        anchors.centerIn: parent

        spacing: defaultMargin * factor
        RowLayout {
            id: buttons
            Layout.alignment: Qt.AlignHCenter
            spacing: defaultMargin * factor
            SGAlignedLabel {
                target: led1
                text: "<b>" + qsTr("INT_ISR") + "</b>"
                fontSizeMultiplier: factor
                alignment: SGAlignedLabel.SideTopCenter
                SGStatusLight {
                    id: led1
                    width: lightSizeValue * factor
                }
            }
        }
        Image {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumWidth: ((lightSizeValue * 1.5 + defaultMargin * 8) * factor) + 30
            Layout.maximumHeight: (lightSizeValue + 50) * factor
            Layout.alignment: Qt.AlignHCenter
            fillMode:Image.PreserveAspectFit
            source: "Images/helpImage_interrupt.png"
        }
    }
}
