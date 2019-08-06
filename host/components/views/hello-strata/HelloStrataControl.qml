import QtQuick 2.9
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.5

import tech.strata.sgwidgets 1.0

import "control-views"

SGResponsiveScrollView {
    id: root

    signal signalPotentiometerToADCControl
    signal signalPWMHeatGeneratorAndTempSensorControl
    signal signalPWMToFiltersControl
    signal signalDACAndPWMToLEDControl
    signal signalPWMMotorControlControl
    signal signalLightSensorControl
    signal signalLEDDriverControl
    signal signalMechanicalButtonsToInterruptsControl

    property real factor: Math.max(1,Math.min(root.height/root.minimumHeight,root.width/root.minimumWidth))
    property real vFactor: Math.max(1,height/root.minimumHeight)
    property real hFactor: Math.max(1,width/root.minimumWidth)
    property real defaultSpacing: 10
    scrollBarColor: "lightgrey"


    Rectangle {
        id: container
        parent: root.contentItem
        anchors.fill: parent

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
                minimumWidth: (root.minimumWidth-defaultSpacing)/3
                Layout.row: 0
                Layout.column: 0
                Layout.preferredHeight: this.minimumHeight*root.vFactor
                Layout.preferredWidth: this.minimumWidth*root.hFactor
                onZoom: signalPotentiometerToADCControl()
            }

            PWMHeatGeneratorAndTempSensorControl {
                minimumHeight: (root.minimumHeight-defaultSpacing)*0.3
                minimumWidth: (root.minimumWidth-defaultSpacing)/3
                Layout.row: 0
                Layout.column: 1
                Layout.preferredHeight: this.minimumHeight*root.vFactor
                Layout.preferredWidth: this.minimumWidth*root.hFactor
                onZoom: signalPWMHeatGeneratorAndTempSensorControl()
            }

            PWMToFiltersControl {
                minimumHeight: (root.minimumHeight-defaultSpacing)*0.3
                minimumWidth: (root.minimumWidth-defaultSpacing)/3
                Layout.row: 0
                Layout.column: 2
                Layout.preferredHeight: this.minimumHeight*root.vFactor
                Layout.preferredWidth: this.minimumWidth*root.hFactor
                onZoom: signalPWMToFiltersControl()
            }

            DACAndPWMToLEDControl {
                minimumHeight: (root.minimumHeight-defaultSpacing)*0.4
                minimumWidth: (root.minimumWidth-defaultSpacing)/3
                Layout.row: 1
                Layout.column: 0
                Layout.preferredHeight: this.minimumHeight*root.vFactor
                Layout.preferredWidth: this.minimumWidth*root.hFactor
                onZoom: signalDACAndPWMToLEDControl()
            }

            LightSensorControl {
                minimumHeight: (root.minimumHeight-defaultSpacing)*0.4
                minimumWidth: (root.minimumWidth-defaultSpacing)/3
                Layout.row: 1
                Layout.column: 1
                Layout.preferredHeight: this.minimumHeight*root.vFactor
                Layout.preferredWidth: this.minimumWidth*root.hFactor
                onZoom: signalLightSensorControl()
            }

            LEDDriverControl {
                minimumHeight: (root.minimumHeight-defaultSpacing)*0.4
                minimumWidth: (root.minimumWidth-defaultSpacing)/3
                Layout.row: 1
                Layout.column: 2
                Layout.preferredHeight: this.minimumHeight*root.vFactor
                Layout.preferredWidth: this.minimumWidth*root.hFactor
                onZoom: signalLEDDriverControl()
            }

            PWMMotorControlControl {
                minimumHeight: (root.minimumHeight-defaultSpacing)*0.3
                minimumWidth: (root.minimumWidth-defaultSpacing)/3
                Layout.row: 2
                Layout.column: 0
                Layout.preferredHeight: this.minimumHeight*root.vFactor
                Layout.preferredWidth: this.minimumWidth*root.hFactor
                onZoom: signalPWMMotorControlControl()
            }

            Text {
                Layout.row: 2
                Layout.column: 1
                Layout.preferredHeight: (root.minimumHeight-defaultSpacing)*0.3*vFactor
                Layout.preferredWidth: (root.minimumWidth-defaultSpacing)/3*hFactor
                id: projectname
                text: "Hello Strata"
                font.pixelSize: 40*root.factor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: "black"
            }

            MechanicalButtonsToInterruptsControl {
                minimumHeight: (root.minimumHeight-defaultSpacing)*0.3
                minimumWidth: (root.minimumWidth-defaultSpacing)/3
                Layout.row: 2
                Layout.column: 2
                Layout.preferredHeight: this.minimumHeight*root.vFactor
                Layout.preferredWidth: this.minimumWidth*root.hFactor
                onZoom: signalMechanicalButtonsToInterruptsControl()
            }
        }
    }
}
