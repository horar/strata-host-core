import QtQuick 2.12
import tech.strata.sgwidgets 1.0

FocusScope {
    id: delegate

    width: Math.max(text.width, loader.width)
    height: {
        var h = loader.y + loader.height

        if (hasHelperText) {
            h += helperTextItem.paintedHeight + 4
        }

        return h
    }

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
    property bool hasHelperText: true

    /* Set this to True if you want input validation to be handled by editor. */
    property bool inputValidation: false

    /* reimplement this to validate inputs*/
    function inputValidationErrorMsg() {
        return ""
    }

    /* Use these to manually set state.
       This is useful when state depends on async events, for example response from server.
     */
    function setIsUnknown() {
        validStatus = SGBaseEditor.Unknown
        errorText = ""
    }

    function setIsValid() {
        validStatus = SGBaseEditor.Valid
        errorText = ""
    }

    function setIsInvalid(error) {
        validStatus = SGBaseEditor.Invalid
        errorText = error
    }


    enum ValidStatus {
        Unknown,
        Valid,
        Invalid
    }

    property int validStatus: SGBaseEditor.Unknown

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

        setIsUnknown()
    }

    function callInputValidationErrorMsg() {
        var error = inputValidationErrorMsg()
        if (error.length > 0) {
            setIsInvalid(error)
        } else if (error.length === 0) {
            setIsValid()
        }
    }

    SGText {
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
            if (validStatus === SGBaseEditor.Invalid) {
                return errorComponent
            } else if (validStatus === SGBaseEditor.Valid) {
                return okayComponent
            }

            return null
        }
    }

    SGText {
        id: helperTextItem
        anchors {
            left: loader.left
            leftMargin: delegate.spacing
            top: loader.bottom
            topMargin: 1
        }

        visible: hasHelperText
        font.italic: true
        text: validStatus === SGBaseEditor.Invalid ? errorText : helperText
        color: validStatus === SGBaseEditor.Invalid ? SGColorsJS.ERROR_COLOR : Qt.darker("grey",1.5)
    }

    Component {
        id: errorComponent

        Item {
            Rectangle {
                anchors.fill: parent
                radius: Math.round(width/2)
                color: SGColorsJS.ERROR_COLOR
            }

            SGIcon {
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

            SGIcon {
                anchors.centerIn: parent
                height: Math.floor(parent.height - 4)
                width: height
                source: "qrc:/sgimages/check.svg"
                iconColor: "white"
            }
        }
    }
}
