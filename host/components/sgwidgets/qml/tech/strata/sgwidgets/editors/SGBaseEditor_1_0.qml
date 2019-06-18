import QtQuick 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets

FocusScope {
    id: delegate

    width: Math.max(text.width, loader.width)
    height: loader.y + loader.height + helperTextItem.paintedHeight + 4

    focus: true

    readonly property int itemX: loader.x
    readonly property int itemY: loader.y

    property alias label: text.text
    property Component editor
    property alias item: loader.item
    property int listSpacing: 6
    property int spacing: 2
    property string helperText: ""
    property string errorText

    /* Set this to True if you want input validation to be handled by editor. */
    property bool inputValidation: false

    /* reimplement this to validate inputs*/
    function inputValidationErrorMsg() {
        return ""
    }

    enum ValidStatus {
        Unknown,
        Valid,
        Invalid
    }

    property int validStatus: SGWidgets.SGBaseEditor.Unknown

    Connections {
        target: inputValidation && loader.status == Loader.Ready ? loader.item : null
        onActiveFocusChanged: {
            delegate.validate(true)
        }

        onActiveEditingChanged: {
            delegate.validate()
        }

        onValidationReadyChanged: {
            delegate.validate()
        }

        onEnabledChanged: {
            delegate.validate()
        }
    }

    function validate(focusChanged) {
        if (loader.item.enabled) {
            if (focusChanged) {
                if (!loader.item.activeFocus) {
                    //editor lost focus
                    callInputValidationErrorMsg()
                }

                return
            } else if (loader.item.validationReady && !loader.item.activeEditing) {
                callInputValidationErrorMsg()
                return
            }
        }

        validStatus = SGWidgets.SGBaseEditor.Unknown
        errorText = ""
    }

    function callInputValidationErrorMsg() {
        errorText = inputValidationErrorMsg()
        if (errorText.length > 0) {
            validStatus = SGWidgets.SGBaseEditor.Invalid
        } else if (errorText.length === 0) {
            validStatus = SGWidgets.SGBaseEditor.Valid
        }
    }

    SGWidgets.SGText {
        id: text
        anchors {
            left: loader.left
            leftMargin: delegate.spacing
            top: parent.top
        }

        fontSizeMultiplier: 1.1
    }

    Loader {
        id: loader
        anchors {
            left: parent.left
            top: text.bottom
            bottomMargin: delegate.spacing
        }

        sourceComponent: delegate.editor
        focus: true
    }

    Loader {
        anchors {
            right: loader.right
            rightMargin: delegate.spacing
            bottom: loader.top
        }

        height: helperTextItem.font.pixelSize + 4
        width: height

        sourceComponent: {
            if (validStatus === SGWidgets.SGBaseEditor.Invalid) {
                return errorComponent
            } else if (validStatus === SGWidgets.SGBaseEditor.Valid) {
                return okayComponent
            }

            return null
        }
    }

    SGWidgets.SGText {
        id: helperTextItem
        anchors {
            left: loader.left
            leftMargin: delegate.spacing
            top: loader.bottom
            topMargin: 1
        }

        //fontSizeMultiplier: 0.9
        font.italic: true
        text: validStatus === SGWidgets.SGBaseEditor.Invalid ? errorText : helperText
        color: validStatus === SGWidgets.SGBaseEditor.Invalid ? SGWidgets.SGColorsJS.ERROR_COLOR : Qt.darker("grey",1.5)
    }

    Component {
        id: errorComponent

        Item {
            Rectangle {
                anchors.fill: parent
                radius: Math.round(width/2)
                color: SGWidgets.SGColorsJS.ERROR_COLOR
            }

            SGWidgets.SGIcon {
                anchors.centerIn: parent
                height: Math.floor(parent.height - 4)
                width: height
                source: "qrc:/sgimages/exclamation.svg"
                iconColor: "white"
            }
        }
    }

    Component {
        id: okayComponent

        Item {
            Rectangle {
                anchors.fill: parent
                radius: Math.round(width/2)
                color: Qt.lighter("green")
            }

            SGWidgets.SGIcon {
                anchors.centerIn: parent
                height: Math.floor(parent.height - 4)
                width: height
                source: "qrc:/sgimages/check.svg"
                iconColor: "white"
            }
        }
    }
}
