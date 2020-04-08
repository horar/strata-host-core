import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0

Item {
    width: contentColumn.width
    height: editEnabledCheckBox.y + editEnabledCheckBox.height

    Column {
        id: contentColumn
        spacing: 10
        enabled: editEnabledCheckBox.checked

        SGAlignedLabel {
            id: demoLabel
            target: sgStatusLight
            text: "Status"
            fontSizeMultiplier: 1.3

            SGStatusLight {
                id: sgStatusLight
                // Useful Signals:
                onStatusChanged: console.info("Changed to " + status)
            }
        }

        Row {
            spacing: 10

            SGButton {
                id: switchStatus
                text: "Switch Status"
                onClicked: {
                    if (sgStatusLight.status > 5) { sgStatusLight.status = 0 } else { sgStatusLight.status++ }
                }
            }

            SGButton {
                id: toggleStyle
                text: "Toggle Flat Style"
                onClicked: {
                    sgStatusLight.flatStyle = ! sgStatusLight.flatStyle
                }
            }
        }

        SGAlignedLabel {
            id: demoLabel2
            target: sgStatusLightCustomize
            text: "Customize LED Light Color"
            fontSizeMultiplier: 1.3


            SGStatusLight {
                id: sgStatusLightCustomize

                // Optional Configuration:
                status: SGStatusLight.CustomColor   // Default: "SGStatusLight.Off" (see notes below)
                customColor: "pink"                 // Default: white (must set the status to SGStatusLight.CustomColor to use this color)

                // Useful Signals:
                onStatusChanged: console.info("Changed to " + status)
            }
        }

        SGButton {
            id: switchStatus2
            text: "Randomize Custom Color"
            onClicked: {
                sgStatusLightCustomize.customColor = Qt.rgba(Math.random()*0.5 + 0.25, Math.random()*0.5 + 0.25, Math.random()*0.5 + 0.25, 1)
            }
        }
    }

    SGCheckBox {
        id: editEnabledCheckBox
        anchors {
            top: contentColumn.bottom
            topMargin: 20
        }

        text: "Everything enabled"
        checked: true
        onCheckedChanged: {
            if (checked) {
                sgStatusLightCustomize.opacity = 1.0
                sgStatusLight.opacity = 1.0
            }
            else {
                sgStatusLightCustomize.opacity = 0.5
                sgStatusLight.opacity = 0.5
            }
        }
    }
}
