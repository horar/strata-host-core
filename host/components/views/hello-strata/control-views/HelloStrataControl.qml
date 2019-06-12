import QtQuick 2.9
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.5

import tech.strata.sgwidgets 1.0

import "qrc:/js/help_layout_manager.js" as Help

SGResponsiveScrollView {
    id: root

    minimumHeight: 660+20
    minimumWidth: 850+20

    signal signalPotentiometerToADCControl
    signal signalPWMHeatGeneratorAndTempSensorControl
    signal signalPWMToFiltersControl
    signal signalDACAndPWMToLEDControl
    signal signalPWMMotorControlControl
    signal signalLightSensorControl
    signal signalLEDDriverControl
    signal signalMechanicalButtonsToInterruptsControl

    property var factor: min(root.height/root.minimumHeight,root.width/root.minimumWidth)

    function min(a,b) {
        return a<b ? a : b
    }

    Rectangle {
        id: container
        parent: root.contentItem
        anchors.fill: parent

        GridLayout {
            rows: 3
            columns: 3

            rowSpacing: 10
            columnSpacing: 10

            PotentiometerToADCControl {
                Layout.row: 0
                Layout.column: 0
                Layout.preferredHeight: this.height
                Layout.preferredWidth: this.width
                height: this.minimumHeight*root.factor
                width: this.minimumWidth*root.factor
                onZoom: signalPotentiometerToADCControl()
            }

            PWMHeatGeneratorAndTempSensorControl {
                Layout.row: 0
                Layout.column: 1
                Layout.preferredHeight: this.height
                Layout.preferredWidth: this.width
                height: this.minimumHeight*root.factor
                width: this.minimumWidth*root.factor
                onZoom: signalPWMHeatGeneratorAndTempSensorControl()
            }

            PWMToFiltersControl {
                Layout.row: 0
                Layout.column: 2
                Layout.preferredHeight: this.height
                Layout.preferredWidth: this.width
                height: this.minimumHeight*root.factor
                width: this.minimumWidth*root.factor
                onZoom: signalPWMToFiltersControl()
            }

            DACAndPWMToLEDControl {
                Layout.row: 1
                Layout.column: 0
                Layout.preferredHeight: this.height
                Layout.preferredWidth: this.width
                height: this.minimumHeight*root.factor
                width: this.minimumWidth*root.factor
                onZoom: signalDACAndPWMToLEDControl()
            }

            LightSensorControl {
                Layout.row: 1
                Layout.column: 1
                Layout.preferredHeight: this.height
                Layout.preferredWidth: this.width
                height: this.minimumHeight*root.factor
                width: this.minimumWidth*root.factor
                onZoom: signalLightSensorControl()
            }

            LEDDriverControl {
                Layout.row: 1
                Layout.column: 2
                Layout.preferredHeight: this.height
                Layout.preferredWidth: this.width
                height: this.minimumHeight*root.factor
                width: this.minimumWidth*root.factor
                onZoom: signalLEDDriverControl()
            }

            PWMMotorControlControl {
                Layout.row: 2
                Layout.column: 0
                Layout.preferredHeight: this.height
                Layout.preferredWidth: this.width
                height: this.minimumHeight*root.factor
                width: this.minimumWidth*root.factor
                onZoom: signalPWMMotorControlControl()
            }

            Text {
                Layout.row: 2
                Layout.column: 1
                Layout.preferredHeight: this.height
                Layout.preferredWidth: this.width
                id: projectname
                text: "Hello Strata"
                height: 660*0.3*root.factor
                width: 850/3*root.factor
                font {
                    pixelSize: 40*root.factor
                }
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: "black"
            }

            MechanicalButtonsToInterruptsControl {
                Layout.row: 2
                Layout.column: 2
                Layout.preferredHeight: this.height
                Layout.preferredWidth: this.width
                height: this.minimumHeight*root.factor
                width: this.minimumWidth*root.factor
                onZoom: signalMechanicalButtonsToInterruptsControl()
            }
        }
    }
}
