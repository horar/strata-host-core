import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.theme 1.0

ProgramSettingsDelegate {
    id: delegate


    property bool isValid: false
    property string title: "Orderable Part Number"
    property string titleWhenSet
    property string opn

    property  bool isSearching: false




    property string errorText

    signal checkOpnRequested(string opn)

    visible: false

    content: Item {
        width: setButton.x + setButton.width
        height: isSet ? opnTextItem.y + opnTextItem.height : errorTextItem.y + errorTextItem.height

        SGWidgets.SGText {
            id: title
            anchors {
                top: parent.top
            }

            text: delegate.isSet ? delegate.titleWhenSet : delegate.title
        }

        SGWidgets.SGTextField {
            id: opnInput
            anchors {
                top: title.bottom
                left: parent.left
                right: setButton.left
                rightMargin: horizontalSpace
            }

            placeholderText: "OPN..."
            contextMenuEnabled: true
            leftIconSource: "qrc:/sgimages/zoom.svg"
            opacity: delegate.isSet ? 0 : 1
            enabled: delegate.isSearching === false && delegate.isSet === false
            font.capitalization: Font.AllUppercase
            maximumLength: 100
            busyIndicatorRunning: delegate.isSearching

            Behavior on opacity { OpacityAnimator {} }

            onTextChanged: {
                delegate.opn = text.toUpperCase()
                errorText = ""
            }

            Keys.onEnterPressed: {
                checkOpnRequested(text)
            }

            Keys.onReturnPressed: {
                checkOpnRequested(text)
            }

            Binding {
                target: opnInput
                property: "text"
                value: delegate.opn
            }
        }

        SGWidgets.SGText {
            id: opnTextItem
            anchors {
                top: title.bottom
                left: title.left
            }

            opacity: delegate.isSet ? 1 : 0
            text: opnInput.text
            fontSizeMultiplier: 1.6

            Behavior on opacity { OpacityAnimator {} }
        }

        SGWidgets.SGText {
            id: errorTextItem
            anchors {
                left: opnInput.left
                top: opnInput.bottom
                topMargin: 1
            }

            font.italic: true
            text:errorText
            color: Theme.palette.error
        }

        SGWidgets.SGButton {
            id: setButton
            anchors {
                right: parent.right
                verticalCenter: opnInput.verticalCenter
            }

            text: "Set"
            opacity: delegate.isSet ? 0 : 1

            onClicked: {
                checkOpnRequested(opnInput.text)
            }
        }
    }
}
