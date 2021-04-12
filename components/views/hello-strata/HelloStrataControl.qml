import QtQuick 2.9
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.5

import "control-views"
import "sgwidgets"

SGResponsiveScrollView {
    id: root

    scrollBarColor: "lightgrey"

    property real factor: Math.max(1,Math.min(root.height/root.minimumHeight,root.width/root.minimumWidth))
    property real vFactor: Math.max(1,height/root.minimumHeight)
    property real hFactor: Math.max(1,width/root.minimumWidth)
    property real defaultSpacing: 10

    signal signalPotentiometerToADCControl
    signal signalPWMHeatGeneratorAndTempSensorControl
    signal signalPWMToFiltersControl
    signal signalDACAndPWMToLEDControl
    signal signalPWMMotorControlControl
    signal signalLightSensorControl
    signal signalLEDDriverControl
    signal signalMechanicalButtonsToInterruptsControl

    Rectangle {
        id: container
        anchors.fill: parent
        parent: root.contentItem

        MouseArea { // to remove focus in input box when click outside
            anchors.fill: parent
            preventStealing: true
            onClicked: focus = true
        }

        GridLayout {
            rows: 3
            columns: 3
            rowSpacing: defaultSpacing/2 * vFactor
            columnSpacing: defaultSpacing/2 * hFactor

            PotentiometerToADCControl {
                minimumHeight: (root.minimumHeight-defaultSpacing)*0.3
                minimumWidth: (root.minimumWidth-defaultSpacing)*0.32
                Layout.preferredHeight: this.minimumHeight*root.vFactor
                Layout.preferredWidth: this.minimumWidth*root.hFactor
                Layout.row: 0
                Layout.column: 0
                onZoom: signalPotentiometerToADCControl()
            }

            PWMHeatGeneratorAndTempSensorControl {
                minimumHeight: (root.minimumHeight-defaultSpacing)*0.3
                minimumWidth: (root.minimumWidth-defaultSpacing)*0.33
                Layout.preferredHeight: this.minimumHeight*root.vFactor
                Layout.preferredWidth: this.minimumWidth*root.hFactor
                Layout.row: 0
                Layout.column: 1
                onZoom: signalPWMHeatGeneratorAndTempSensorControl()
            }

            PWMToFiltersControl {
                minimumHeight: (root.minimumHeight-defaultSpacing)*0.3
                minimumWidth: (root.minimumWidth-defaultSpacing)*0.35
                Layout.preferredHeight: this.minimumHeight*root.vFactor
                Layout.preferredWidth: this.minimumWidth*root.hFactor
                Layout.row: 0
                Layout.column: 2
                onZoom: signalPWMToFiltersControl()
            }

            DACAndPWMToLEDControl {
                minimumHeight: (root.minimumHeight-defaultSpacing)*0.4
                minimumWidth: (root.minimumWidth-defaultSpacing)*0.32
                Layout.preferredHeight: this.minimumHeight*root.vFactor
                Layout.preferredWidth: this.minimumWidth*root.hFactor
                Layout.row: 1
                Layout.column: 0
                onZoom: signalDACAndPWMToLEDControl()


            }

            LightSensorControl {
                minimumHeight: (root.minimumHeight-defaultSpacing)*0.4
                minimumWidth: (root.minimumWidth-defaultSpacing)*0.33
                Layout.preferredHeight: this.minimumHeight*root.vFactor
                Layout.preferredWidth: this.minimumWidth*root.hFactor
                Layout.row: 1
                Layout.column: 1
                onZoom: signalLightSensorControl()
            }

            LEDDriverControl {
                minimumHeight: (root.minimumHeight-defaultSpacing)*0.4
                minimumWidth: (root.minimumWidth-defaultSpacing)*0.35
                Layout.preferredHeight: this.minimumHeight*root.vFactor
                Layout.preferredWidth: this.minimumWidth*root.hFactor
                Layout.row: 1
                Layout.column: 2
                onZoom: signalLEDDriverControl()
            }

            PWMMotorControlControl {
                minimumHeight: (root.minimumHeight-defaultSpacing)*0.3
                minimumWidth: (root.minimumWidth-defaultSpacing)*0.32
                Layout.preferredHeight: this.minimumHeight*root.vFactor
                Layout.preferredWidth: this.minimumWidth*root.hFactor
                Layout.row: 2
                Layout.column: 0
                onZoom: signalPWMMotorControlControl()
            }

            Text {
                id: projectname
                Layout.preferredHeight: (root.minimumHeight-defaultSpacing)*0.3*vFactor
                Layout.preferredWidth: (root.minimumWidth-defaultSpacing)*0.33*hFactor
                Layout.row: 2
                Layout.column: 1
                text: "Hello Strata"
                font.pixelSize: 40*root.factor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: "black"
            }

            MechanicalButtonsToInterruptsControl {
                minimumHeight: (root.minimumHeight-defaultSpacing)*0.3
                minimumWidth: (root.minimumWidth-defaultSpacing)*0.35
                Layout.preferredHeight: this.minimumHeight*root.vFactor
                Layout.preferredWidth: this.minimumWidth*root.hFactor
                Layout.row: 2
                Layout.column: 2
                onZoom: signalMechanicalButtonsToInterruptsControl()
            }
        }
    }
}
