import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets

ProgramSettingsDelegate {
    id: delegate

    property bool onlyController: true

    signal userResponse(bool onlyController)

    content: Item {
        height: buttonRow.y + buttonRow.height

        SGWidgets.SGText {
            id: title

            text: "Do you want to register only a controller ?"
            opacity: isSet ? 0 : 1

            Behavior on opacity { OpacityAnimator {} }
        }

        Row {
            id: buttonRow
            anchors {
                top: title.bottom
                topMargin: verticalSpace
            }

            spacing: horizontalSpace
            opacity: isSet ? 0 : 1

            Behavior on opacity { OpacityAnimator {} }

            SGWidgets.SGButton {
                text: "Controller"
                onClicked: {
                    onlyController = true
                    userResponse(true)
                }
            }

            SGWidgets.SGButton {
                text: "Controller + Assisted Platform"
                onClicked: {
                    onlyController = false
                    userResponse(false)
                }
            }
        }
    }
}
