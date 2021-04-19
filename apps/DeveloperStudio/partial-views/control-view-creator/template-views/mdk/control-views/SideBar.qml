import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQml 2.12

import "qrc:/js/help_layout_manager.js" as Help
import "../widgets"

import tech.strata.sgwidgets 1.0

Rectangle {
    id: sideBar
    color: "#454545"
    implicitWidth: 60
    Layout.fillHeight: true

    Component.onCompleted: {
        Help.registerTarget(runningButton, "Place holder for Basic control view help messages", 0, "BasicControlHelp")
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: 10
        }
        spacing: 20

        SpeedIconButton {
            id: speedButton
        }

        IconButton {
            id: runningButton
            source: running ? "qrc:/images/stop-solid.svg" : "qrc:/images/play-solid.svg"
            iconColor: running ? "#db0909" : "#45e03a"

            property bool running: false

            onClicked:  {
                running = !running
                // start/stop logic here
            }
        }

        IconButton {
            id: brakeButton
            source: "qrc:/images/brake.svg"

            onClicked:  {
                // braking logic here
            }
        }

        IconButton {
            id: forwardReverseButton
            enabled: runningButton.running === false //  direction control disabled when motor running
            opacity: enabled ? 1 : .5
            source: forward ? "qrc:/images/undo.svg" : "qrc:/images/redo-alt-solid.svg"

            property bool forward: false

            onClicked:  {
                forward = !forward
                // directional logic here
            }
        }

        Item {
            // filler
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        ColumnLayout {
            spacing: 8

            FaultLight {
                text: "OCP"
                toolTipText: "Over Current Protection"
                status: SGStatusLight.Off
            }

            FaultLight {
                text: "OVP"
                toolTipText: "Over Voltage Protection"
                status: SGStatusLight.Yellow
            }

            FaultLight {
                text: "OTP"
                toolTipText: "Over Temp Protection"
                status: SGStatusLight.Red
            }

            // add or remove more as needed
        }

        Item {
            // filler
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        IconButton {
            id: helpIcon
            source: "qrc:/sgimages/question-circle.svg" // generic icon from SGWidgets

            onClicked:  {
                // start different help tours depending on which view is visible
                switch (navTabs.currentIndex) {
                case 0:
                    Help.startHelpTour("BasicControlHelp")
                    return
                case 1:
                    Help.startHelpTour("AdvancedControlHelp")
                    return
                }
            }
        }
    }
}
