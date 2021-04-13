import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0

Popup {
    id: addPop
    y: parent.height
    background: Rectangle { }
    padding: 0

    ColumnLayout {
        spacing: 1

        Repeater {
            model: ListModel {

                ListElement {
                    text: "Button"
                    controlUrl: ":/tech/strata/sgwidgets.1.0/cvc-layout/widgets/Button/Button.txt"
                }

                ListElement {
                    text: "Text"
                    controlUrl: ":/tech/strata/sgwidgets.1.0/cvc-layout/widgets/Text/Text.txt"
                }

                ListElement {
                    text: "Divider"
                    controlUrl: ":/tech/strata/sgwidgets.1.0/cvc-layout/widgets/Divider/Divider.txt"
                }

                ListElement {
                    text: "Icon"
                    controlUrl: ":/tech/strata/sgwidgets.1.0/cvc-layout/widgets/SGIcon/SGIcon.txt"
                }

                ListElement {
                    text: "Rectangle"
                    controlUrl: ":/tech/strata/sgwidgets.1.0/cvc-layout/widgets/Rectangle/Rectangle.txt"
                }

                ListElement {
                    text: "RadioButton"
                    controlUrl: ":/tech/strata/sgwidgets.1.0/cvc-layout/widgets/RadioButton/SGRadioButton.txt"
                }
                ListElement {
                    text: "Switch"
                    controlUrl: ":/tech/strata/sgwidgets.1.0/cvc-layout/widgets/Switch/SGSwitch.txt"
                }
                ListElement {
                    text: "InfoBox"
                    controlUrl: ":/tech/strata/sgwidgets.1.0/cvc-layout/widgets/InfoBox/SGInfoBox.txt"
                }
                ListElement {
                    text: "CircularGauge"
                    controlUrl: ":/tech/strata/sgwidgets.1.0/cvc-layout/widgets/CircularGauge/SGCircularGauge.txt"
                }
                ListElement {
                    text: "StatusLight"
                    controlUrl: ":/tech/strata/sgwidgets.1.0/cvc-layout/widgets/StatusLight/SGStatusLight.txt"
                }
                ListElement {
                    text: "ComboBox"
                    controlUrl: ":/tech/strata/sgwidgets.1.0/cvc-layout/widgets/ComboBox/SGComboBox.txt"
                }
                ListElement {
                    text: "Graph"
                    controlUrl: ":/tech/strata/sgwidgets.1.0/cvc-layout/widgets/Graph/SGGraph.txt"
                }
                ListElement {
                    text: "Slider"
                    controlUrl: ":/tech/strata/sgwidgets.1.0/cvc-layout/widgets/Slider/SGSlider.txt"
                }
                ListElement {
                    text: "ButtonStrip"
                    controlUrl: ":/tech/strata/sgwidgets.1.0/cvc-layout/widgets/ButtonStrip/SGButtonStrip.txt"
                }
            }

            delegate: Button {
                text: model.text
                Layout.preferredHeight: 20
                Layout.preferredWidth : 110

                onClicked: {
                    visualEditor.functions.addControl(model.controlUrl)
                    addPop.close()
                }
            }
        }
    }
}
