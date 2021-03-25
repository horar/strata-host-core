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
            }

            delegate: Button {
                text: model.text
                implicitHeight: 20

                onClicked: {
                    visualEditor.functions.addControl(model.controlUrl)
                    addPop.close()
                }
            }
        }
    }
}
