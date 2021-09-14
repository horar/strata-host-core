import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.12

import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0
import tech.strata.theme 1.0

TextField {
    id: field
    placeholderText: ""
    selectByMouse: true
    maximumLength: 256
    Layout.fillWidth: true
    font {
        pixelSize: 15
        family: Fonts.franklinGothicBook
    }
    selectionColor:"lightgrey"
    rightPadding: hasRightIcons ? rightIcons.width + 5+5 : 5
    persistentSelection: true   // must deselect manually

    echoMode: {
        if (passwordMode && revealPassword === false) {
            return TextField.Password
        }

        return TextField.Normal
    }

    onActiveFocusChanged: {
        if ((activeFocus === false) && (contextMenuPopup.visible === false)) {
            field.deselect()
        }
    }

    property bool valid: field.text !== ""
    property bool showIcon: true
    property bool passwordMode: false

    /* private */
    property bool revealPassword: false
    property bool hasRightIcons: showIcon || revelPasswordLoader.status ===  Loader.Ready

    SGContextMenuEditActions {
        id: contextMenuPopup
        textEditor: field
        copyEnabled: field.echoMode !== TextField.Password
        z: 1 // to appear above Password Requirement popup in Register screen
    }

    background: Rectangle {
        id: backgroundContainer
        implicitHeight: 32
        border.width: field.activeFocus ? 1 : 0
        border.color:  field.activeFocus ? Theme.palette.onsemiOrange : "#40000000"
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 2
            color: "#40000000"
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.IBeamCursor
            acceptedButtons: Qt.RightButton
            onClicked: {
                field.forceActiveFocus()
            }
            onReleased: {
                if (containsMouse) {
                    contextMenuPopup.popup(null)
                }
            }
        }

        Row {
            id: rightIcons
            height: parent.height
            anchors {
                right: parent.right
                rightMargin: 5
            }

            spacing: 5

            Loader {
                id: revelPasswordLoader
                anchors {
                    verticalCenter: parent.verticalCenter
                }

                sourceComponent: passwordMode ? revealPasswordComponent : undefined
            }

            Loader {
                id: validationIconLoader
                anchors {
                    top: rightIcons.top
                    topMargin: 5
                }

                sourceComponent: showIcon ? validationIconComponent : undefined
            }
        }
    }

    Component {
        id: validationIconComponent

        SGIcon {
            id: validIcon
            height: field.valid ? field.height * .33 : field.height * .25
            width: height

            source: field.valid ? "qrc:/sgimages/check.svg" : "qrc:/sgimages/asterisk.svg"
            iconColor: field.valid ? "#30c235" : "#ddd"
        }
    }

    Component {
        id: revealPasswordComponent

        SGIcon {
            id: showPasswordIcon
            height: field.height * 0.75
            width: height

            source: field.revealPassword ? "qrc:/sgimages/eye-slash.svg" : "qrc:/sgimages/eye.svg"
            iconColor: showPasswordMouseArea.containsMouse ? "lightgrey" : "#ddd"

            MouseArea {
                id: showPasswordMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onPressedChanged: {
                    revealPassword = pressed
                }
            }
        }
    }
}
