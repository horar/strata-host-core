import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import "qrc:/partial-views"
import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0

Popup {
    id: root
    width: 400
    height: confirmationContainer.height
    x: parent.width/2 - width/2
    y: parent.height/2 - height/2
    modal: true
    padding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    property alias titleText: confirmTitle.text
    property alias saveButtonText: saveButton.text
    property alias closeButtonText: closeButton.text
    property alias cancelButtonText: cancelButton.text
    property alias popupText: confirmText.text
    property alias saveButton: saveButton
    property alias closeButton: closeButton
    property alias cancelButton: cancelButton

    property color saveButtonColor: SGColorsJS.STRATA_GREEN
    property color saveButtonHoverColor: Qt.darker(saveButtonColor, 1.25)
    property color closeButtonColor: "#db2e1e"
    property color closeButtonHoverColor: Qt.darker(closeButtonColor, 1.25)
    property color cancelButtonColor: "#999"
    property color cancelButtonHoverColor: "#666"

    signal saved()
    signal cancelled()
    signal closed()

    DropShadow {
        width: root.width
        height: root.height
        horizontalOffset: 1
        verticalOffset: 3
        radius: 15.0
        samples: 30
        color: "#cc000000"
        source: root.background
        z: -1
        cached: true
    }

    Rectangle {
        id: confirmationContainer
        width: root.width
        height: childrenRect.height + column2.spacing

        Column {
            id: column2
            spacing: 20
            anchors {
                left: confirmationContainer.left
                right: confirmationContainer.right
            }

            Rectangle {
                id: confirmTitleBox
                height: 30
                width: confirmationContainer.width
                color: "lightgrey"

                Label {
                    id: confirmTitle
                    anchors {
                        left: confirmTitleBox.left
                        leftMargin: 10
                        verticalCenter: confirmTitleBox.verticalCenter
                        verticalCenterOffset: 2
                    }
                    text: "Confirmation Message"
                    color: "black"
                }

                SGIcon {
                    id: confirmTitleText
                    source: "qrc:/sgimages/times.svg"
                    iconColor: closeconfirmMouse.containsMouse ? "#eee" : "white"
                    height: 20
                    width: height

                    anchors {
                        right: confirmTitleBox.right
                        verticalCenter: confirmTitleBox.verticalCenter
                        rightMargin: 10
                    }

                    MouseArea {
                        id: closeconfirmMouse
                        anchors {
                            fill: confirmTitleText
                        }
                        onClicked: {
                            root.cancelled()
                            root.close()
                        }
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }

            Row {
                anchors {
                    horizontalCenter: column2.horizontalCenter
                }

                Text {
                    id: confirmText
                    color: "black"
                    text: "Are you sure you would like to continue?"
                }
            }

            Row {
                id: row1
                spacing: 20
                anchors {
                    horizontalCenter: column2.horizontalCenter
                }

                Button {
                    id: saveButton
                    text: "Save"

                    contentItem: Text {
                        text: saveButton.text
                        font.pixelSize: 12
                        font.family: Fonts.franklinGothicBook
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    background: Rectangle {
                        id: saveBtnBg
                        implicitWidth: 100
                        implicitHeight: 40
                        color: saveButtonColor
                    }

                    onClicked: {
                        root.saved()
                        root.close()
                    }

                    Accessible.onPressAction: function() {
                        clicked()
                    }

                    MouseArea {
                        id: saveBtnCursor

                        hoverEnabled: true
                        anchors.fill: parent
                        onPressed:  mouse.accepted = false
                        cursorShape: Qt.PointingHandCursor

                        onEntered: {
                            saveBtnBg.color = saveButtonHoverColor
                        }

                        onExited: {
                            saveBtnBg.color = saveButtonColor
                        }
                    }
                }

                Button {
                    id: closeButton
                    text: "Don't save"

                    contentItem: Text {
                        text: closeButton.text
                        font.pixelSize: 12
                        font.family: Fonts.franklinGothicBook
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    background: Rectangle {
                        id: closeBtnBg
                        implicitWidth: 100
                        implicitHeight: 40
                        color: closeButtonColor
                    }

                    onClicked: {
                        root.closed()
                        root.close()
                    }

                    Accessible.onPressAction: function() {
                        clicked()
                    }

                    MouseArea {
                        id: closeBtnCursor

                        hoverEnabled: true
                        anchors.fill: parent
                        onPressed:  mouse.accepted = false
                        cursorShape: Qt.PointingHandCursor

                        onEntered: {
                            closeBtnBg.color = closeButtonHoverColor
                        }

                        onExited: {
                            closeBtnBg.color = closeButtonColor
                        }
                    }
                }

                Button {
                    id: cancelButton
                    text: "Cancel"
                    visible: text !== ""

                    contentItem: Text {
                        text: cancelButton.text
                        font.pixelSize: 12
                        font.family: Fonts.franklinGothicBook
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    background: Rectangle {
                        id: cancelBtnBg
                        implicitWidth: 100
                        implicitHeight: 40
                        color: cancelButtonColor
                    }

                    onClicked: {
                        root.cancelled()
                        root.close()
                    }

                    Accessible.onPressAction: function() {
                        clicked()
                    }

                    MouseArea {
                        id: cancelBtnCursor

                        hoverEnabled: true
                        anchors.fill: parent
                        onPressed:  mouse.accepted = false
                        cursorShape: Qt.PointingHandCursor

                        onEntered: {
                            cancelBtnBg.color = cancelButtonHoverColor
                        }

                        onExited: {
                            cancelBtnBg.color = cancelButtonColor
                        }
                    }
                }
            }
        }
    }
}
