import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQml.Models 2.12
import QtGraphicalEffects 1.12
import tech.strata.sgwidgets 1.0 as SGWidgets

Popup {
    id: popup

    property Item textEditor
    property variant model
    property Component delegate: delegateComponent
    property Component highlight: highlightComponent
    property Component header: headerComponent
    property alias footer: view.footer
    property string textRole: "text"
    property int listSpacing: 0
    property bool controlWithSpace: false
    property bool closeOnSelection: true
    property bool closeOnDown: false
    property bool openOnActiveFocus: false
    property int maxHeight: 120
    property int position: Item.Bottom
    property int verticalLayoutDirection: ListView.TopToBottom
    property string emptyModelText: "No suggestions."
    property string headerText
    property bool delegateNumbering: false

    signal delegateSelected(int index)

    x: {
        if (!textEditor) {
            return 0
        }

        var pos = textEditor.mapToItem(popup.parent, 0, 0)
        return  pos.x
    }
    y: {
        if (!textEditor) {
            return 0
        }

        var deltaY = 0

        if (position === Item.Bottom) {
            deltaY = textEditor.height
        }

        if (position === Item.Top) {
            deltaY = -popup.contentItem.height - popup.topPadding - popup.bottomPadding
        }

        var pos = textEditor.mapToItem(popup.parent, 0, deltaY)
        return  pos.y
    }

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    padding: 2
    implicitWidth: textEditor ? textEditor.width : 0

    onAboutToShow: {
        if (position === Item.Bottom) {
            view.currentIndex = 0
            view.positionViewAtBeginning()
        } else if (position === Item.Top) {
            view.currentIndex = view.count - 1
            view.positionViewAtEnd()
        }
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

        implicitHeight: Math.min(view.y + view.contentHeight, maxHeight)
        implicitWidth: view.width

        Keys.onPressed: {
            if (event.key === Qt.Key_Up) {
                view.decrementCurrentIndex()
            } else if (event.key === Qt.Key_Down) {
                if (closeOnDown && position === Item.Top) {
                    if (view.currentIndex === view.count - 1) {
                        popup.close()
                    }
                }

                view.incrementCurrentIndex()
            } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                if (popup.opened) {
                    delegateSelected(view.currentIndex)
                    if (closeOnSelection) {
                        popup.close()
                    }
                }
            } else if (controlWithSpace && event.key === Qt.Key_Space) {
                if (popup.opened) {
                    popup.close()
                } else {
                    popup.open()
                }
            } else if (delegateNumbering && event.key >= Qt.Key_0 && event.key <= Qt.Key_9) {
                var effectiveIndex = toModelIndex(event.key - Qt.Key_0)
                if (effectiveIndex >= 0) {
                    view.currentIndex = effectiveIndex
                }
            } else {
                return
            }

            event.accepted = true
        }

        Loader {
            id: headerLoader
            anchors {
                top: parent.topt
            }
            width: view.width

            sourceComponent: headerText ? headerComponent : null
        }

        ListView {
            id: view
            width: textEditor ? textEditor.width - popup.leftPadding - popup.rightPadding : 0
            height: parent.height - headerLoader.height
            anchors {
                top: headerLoader.bottom
            }

            model: popup.model
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.VerticalFlick
            delegate: popup.delegate
            spacing: popup.spacing
            highlightFollowsCurrentItem: true
            highlightMoveDuration: -1
            highlightMoveVelocity: -1
            highlight: popup.highlight
            header: count > 0 ? null : emptyModelComponent

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
                topMargin: position === Item.Bottom ? glowRadius - 2 : 0
                bottomMargin: position === Item.Top ? glowRadius - 2 : 0
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
        id: emptyModelComponent

        Item {
            width: ListView.view.width
            height: text.paintedHeight + 6

            SGWidgets.SGText {
                id: text
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: 2
                    right: parent.right
                    rightMargin: 2 + 8
                }

                text: emptyModelText
                font.italic: true
            }
        }
    }

    Component {
        id: delegateComponent
        Item {
            width: ListView.view.width
            height: text.paintedHeight + 6

            Item {
                id: delegateNumberWrapper
                width: 15
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                }

                visible: delegateNumbering

                Rectangle {
                    anchors.fill: parent
                    color: "black"
                    opacity: 0.05
                }

                SGWidgets.SGText {
                    anchors.centerIn: parent

                    color: text.color
                    opacity: 0.7
                    text: {
                        var number = fromModelIndex(model.index)
                        if (number > 10) {
                            return ""
                        }

                        return number % 10
                    }
                }
            }

            SGWidgets.SGText {
                id: text
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: delegateNumberWrapper.visible ? delegateNumberWrapper.right : parent.left
                    leftMargin: 4
                    right: parent.right
                    rightMargin: 2 + 8
                }

                elide: Text.ElideRight
                text: popup.textRole? model[popup.textRole] : modelData
                alternativeColorEnabled: parent.ListView.isCurrentItem
            }

            MouseArea {
                anchors.fill: parent
                onClicked: delegateSelected(index)
            }
        }
    }

    Component {
        id: headerComponent

        Item {
            height: text.paintedHeight + 6

            Rectangle {
                anchors.fill: parent
                color: "black"
                opacity: 0.05
            }

            SGWidgets.SGText {
                id: text
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: 2
                    right: parent.right
                    rightMargin: 2 + 8
                }

                fontSizeMultiplier: 1.1
                font.bold: true
                text: headerText
            }
        }
    }

    function toModelIndex(number) {
        if (number === 0) {
            number = 10
        }

        if (position === Item.Top) {
            return model.count - number
        }


        return number - 1
    }

    function fromModelIndex(index) {
        if (position === Item.Top) {
            return model.count - index
        }

        return model.index + 1
    }
}
