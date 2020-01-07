import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.logger 1.0

Item {

    width: contentColumn.width
    height: editEnabledCheckBox.y + editEnabledCheckBox.height

    Column {
        id: contentColumn
        spacing: 10
        enabled: editEnabledCheckBox.checked

        Column {
            SGWidgets.SGText {
                text: "Default"
                fontSizeMultiplier: 1.3
            }

            SGWidgets.SGButton {
                text: "button1"
                onClicked: {
                    console.info(Logger.wgCategory, "button1")
                }
            }
        }

        Column {
            SGWidgets.SGText {
                text: "Checkable"
                fontSizeMultiplier: 1.3
            }

            SGWidgets.SGButton {
                id: button2
                text: "button2"
                checkable: true
                onClicked: {
                    console.info(Logger.wgCategory, "button2")
                }
            }

            SGWidgets.SGText {
                text: "checked=" + button2.checked
            }
        }

        Column {
            SGWidgets.SGText {
                text: "Alternative text color"
                fontSizeMultiplier: 1.3
            }

            SGWidgets.SGButton {
                text: "button 3"
                alternativeColorEnabled: true
            }
        }

        Column {

            SGWidgets.SGText {
                text: "With icon"
                fontSizeMultiplier: 1.3
            }

            Row {
                spacing: 10

                SGWidgets.SGButton {
                    text: "button4"
                    icon.source: "qrc:/sgimages/cog.svg"
                    display: Button.TextBesideIcon
                }

                SGWidgets.SGButton {
                    text: "button5"
                    icon.source: "qrc:/sgimages/cog.svg"
                    display: Button.TextUnderIcon
                }

                SGWidgets.SGButton {
                    text: "button6"
                    icon.source: "qrc:/sgimages/cog.svg"
                    iconColor: "blue"
                    display: Button.TextUnderIcon
                }
            }
        }

        Column {
            SGWidgets.SGText {
                text: "Customized colors"
                fontSizeMultiplier: 1.3
            }

            Row {
                spacing: 6
                SGWidgets.SGButton {
                    text: "button7"
                    color: SGWidgets.SGColorsJS.STRATA_GREEN
                }

                SGWidgets.SGButton {
                    text: "button8"
                    color: SGWidgets.SGColorsJS.WARNING_COLOR
                }

                SGWidgets.SGButton {
                    text: "button9"
                    color: SGWidgets.SGColorsJS.ERROR_COLOR
                    alternativeColorEnabled: true
                }
            }
        }

        Column {
            SGWidgets.SGText {
                text: "Adjusted width"
                fontSizeMultiplier: 1.3
            }

            Column {
                spacing: 6

                SGWidgets.SGButton {
                    text: "Option 1"
                    minimumContentWidth: 200
                }

                SGWidgets.SGButton {
                    text: "Option 2 Option 2"
                    minimumContentWidth: 200
                }

                SGWidgets.SGButton {
                    text: "Option 3"
                    minimumContentWidth: 200
                }
            }
        }
    }

    SGWidgets.SGCheckBox {
        id: editEnabledCheckBox
        anchors {
            top: contentColumn.bottom
            topMargin: 20
        }

        text: "Everything enabled"
        checked: true
    }
}
