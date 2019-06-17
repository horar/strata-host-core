import QtQuick 2.12
import "./Colors.js" as Colors

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

    property int validStatus: SgBaseEditor.Unknown

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
    }


    function validate(focusChanged) {
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

        validStatus = SgBaseEditor.Unknown
        errorText = ""
    }

    function callInputValidationErrorMsg() {
        errorText = inputValidationErrorMsg()
        if (errorText.length > 0) {
            validStatus = SgBaseEditor.Invalid
        } else if (errorText.length === 0) {
            validStatus = SgBaseEditor.Valid
        }
    }

    SgText {
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
            if (validStatus === SgBaseEditor.Invalid) {
                return errorComponent
            } else if (validStatus === SgBaseEditor.Valid) {
                return okayComponent
            }

            return null
        }
    }

    SgText {
        id: helperTextItem
        anchors {
            left: loader.left
            leftMargin: delegate.spacing
            top: loader.bottom
            topMargin: 1
        }

        //fontSizeMultiplier: 0.9
        font.italic: true
        text: validStatus === SgBaseEditor.Invalid ? errorText : helperText
        color: validStatus === SgBaseEditor.Invalid ? Colors.ERROR_COLOR : Qt.darker("grey",1.5)
    }

    Component {
        id: errorComponent

        Item {
            Rectangle {
                anchors.fill: parent
                radius: Math.round(width/2)
                color: Colors.ERROR_COLOR
            }

            SgIcon {
                anchors.centerIn: parent
                height: Math.floor(parent.height - 4)
                width: height
                source: "qrc:/images/exclamation.svg"
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

            SgIcon {
                anchors.centerIn: parent
                height: Math.floor(parent.height - 4)
                width: height
                source: "qrc:/images/check.svg"
                iconColor: "white"
            }
        }
    }
}
