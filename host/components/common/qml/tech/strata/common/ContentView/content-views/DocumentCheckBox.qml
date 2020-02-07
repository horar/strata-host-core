import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets

CheckBox {
    id: control

    property bool fakeEnabled: false

    opacity: enabled || fakeEnabled ? 1 : 0.5

    indicator: Rectangle {
        id: outerRadio
        implicitWidth: 20
        implicitHeight: 20


        x: text ? control.leftPadding : control.leftPadding + (control.availableWidth - width) / 2
        y: control.topPadding + (control.availableHeight - height) / 2

        radius: width / 2
        color: "transparent"
        border.width: 1
        border.color: "white"

        Rectangle {
            id: innerRadio
            implicitWidth: parent.width - 8
            implicitHeight: implicitWidth
            anchors.centerIn: parent

            radius: width / 2
            opacity: enabled || fakeEnabled ? 1.0 : 0.3
            color: "white"
            visible: control.checked
        }
    }

    contentItem: SGWidgets.SGText {
        leftPadding: control.indicator && !control.mirrored ? control.indicator.width + control.spacing : 0
        rightPadding: control.indicator && control.mirrored ? control.indicator.width + control.spacing : 0
        text: control.text
        alternativeColorEnabled: true
        verticalAlignment: Text.AlignVCenter
    }
}
