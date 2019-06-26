import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles 1.4
import tech.strata.sgwidgets 0.9
import tech.strata.theme 1.0

Item{
    id: root
    property real infoBoxHeight: 30
    property real infoBoxWidth: 75
    property real sliderHeight: 200
    property real sliderWidth: 20
    property alias switchHeight: sgswitch.switchHeight
    property alias switchWidth: sgswitch.switchWidth
    property alias label: label.text
    property alias labelSize: label.font.pixelSize
    property alias switchLabel: switchlabel.text
    property real switchLabelSize: 12
    property real infoBoxFontSize: 12
    property string checkedLabel: sgswitch.checkedLabel
    property string uncheckedLabel: sgswitch.uncheckedLabel

    signal released()
    signal canceled()
    signal clicked()
    signal toggled()
    signal press()
    signal pressAndHold()

    signal moved()
    signal userSet()
    signal programmaticallySet()

    property alias pressed: sgswitch.pressed
    property alias down: sgswitch.down
    property alias checked: sgswitch.checked

    property bool sliderStatus
    property real slider_label_opacity: 0.5
    property var slider_value
    property alias slider_set_initial_value: vslider.value


    Column {
        spacing: 5
        Text {
            id: label
            text: "D1"
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Rectangle {
            id: infoBox
            height: root.infoBoxHeight
            width: root.infoBoxWidth
            border.width: 1
            opacity: slider_label_opacity
            Text {
                text: (vslider.value * 100).toFixed(1) + "%"
                font.pixelSize: infoBoxFontSize
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }
            }
            anchors.horizontalCenter: parent.horizontalCenter
        }


        Slider {
            id: vslider
            height: root.sliderHeight
            width: root.sliderWidth
            enabled: sliderStatus
            opacity: slider_label_opacity



            //onMoved: root.moved()
            onPressedChanged: {
                if(!pressed){
                    slider_value = value
                }
            }


            orientation: Qt.Vertical
            anchors.horizontalCenter: parent.horizontalCenter

        }

        Text {
            id: switchlabel
            text: "Enable"
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: switchLabelSize
        }
        SGSwitch {
            id: sgswitch
            checkedLabel: "On"
            uncheckedLabel: "Off"
            anchors.horizontalCenter: parent.horizontalCenter
            onToggled: root.toggled()
            onReleased: root.released()
            onCanceled: root.canceled()
            onClicked: root.clicked()
            //onPressed: root.press()
            onPressAndHold: root.pressAndHold()


        }
    }
}
