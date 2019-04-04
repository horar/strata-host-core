import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQml.Models 2.12
import QtGraphicalEffects 1.12

Popup {
    id: popup

    property Item textEditor
    property variant model
    property Component delegate: delegateComponent
    property Component highlight: highlightComponent
    property alias footer: view.footer
    property string textRole: "text"
    property int listSpacing: 0
    property bool controlWithSpace: false
    property bool closeOnSelection: true
    property bool openOnActiveFocus: false
    property int maxHeight: 120
    property int maxWidth: 300

    signal delegateSelected(int index)

    x: 0
    y: textEditor.height

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    padding: 2
    implicitWidth: textEditor ? textEditor.width : 0

    onAboutToShow: {
        view.currentIndex = 0
    }

    Connections {
        target: textEditor
        onActiveFocusChanged: {
            if (textEditor.activeFocus) {
                if (openOnActiveFocus) {
                    popup.open()
                }
            } else {
                popup.close()
            }
        }
    }

    Control {
        id: dummyControl
    }

    contentItem: Item {
        id: wrapper

        implicitHeight: Math.min(view.contentHeight, maxHeight)
        clip: true

        Keys.onPressed: {
            if (event.key === Qt.Key_Up) {
                view.decrementCurrentIndex()
            }
            else if (event.key === Qt.Key_Down) {
                view.incrementCurrentIndex()
            }  else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                if (popup.opened) {
                    delegateSelected(view.currentIndex)
                    if (closeOnSelection) {
                        popup.close()
                    }
                }
            }
            else if (controlWithSpace && event.key === Qt.Key_Space) {
                if (popup.opened) {
                    popup.close()
                } else {
                    popup.open()
                }
            } else {
                return
            }

            event.accepted = true
        }

        ListView {
            id: view
            width: textEditor ? textEditor.width : 0
            height: parent.height

            model: popup.model
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.VerticalFlick
            delegate: popup.delegate
            spacing: popup.spacing
            highlightFollowsCurrentItem: true
            highlightMoveDuration: -1
            highlightMoveVelocity: -1
            highlight: popup.highlight
            header: count > 0 ? null : headerComponent

            ScrollBar.vertical: ScrollBar {
                anchors {
                    top: view.top
                    bottom: view.bottom
                    right: view.right
                    rightMargin: 2
                }

                policy: ScrollBar.AlwaysOn
                interactive: false
                width: 8
                visible: view.height < view.contentHeight
            }
        }
    }

    background: Item {

        RectangularGlow {
            id: effect
            anchors {
                fill: parent
                topMargin: glowRadius - 2
            }
            glowRadius: 8
            color: dummyControl.palette.mid
        }

        Rectangle {
            anchors.fill: parent
            color: "white"
            border.color: dummyControl.palette.mid
            border.width: 1
        }
    }

    Component {
        id: highlightComponent
        Rectangle {
            color: dummyControl.palette.highlight
        }
    }

    Component {
        id: headerComponent

        Item {
            width: ListView.view ? ListView.view.width : 0
            height: text.paintedHeight + 6

            SgText {
                id: text
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: 2
                    right: parent.right
                    rightMargin: 2 + 8
                }

                text: "No suggestions."
                font.italic: true
            }
        }
    }

    Component {
        id: delegateComponent
        Item {
            width: ListView.view.width
            height: text.paintedHeight + 6

            SgText {
                id: text
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: 2
                    right: parent.right
                    rightMargin: 2 + 8
                }

                elide: Text.ElideRight
                text: popup.textRole ? model[popup.textRole] : modelData
                hasAlternativeColor: parent.ListView.isCurrentItem
            }

            MouseArea {
                anchors.fill: parent
                onClicked: delegateSelected(index)
            }
        }
    }
}
