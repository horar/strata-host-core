import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets

Item {
    id: delegate

    height: contentLoader.y + contentLoader.height + bottomPadding

    property int bottomPadding: 1
    property bool pressable: true
    property bool checked: false
    property bool uncheckable: false
    property bool whiteBgWhenSelected: true
    property alias headerSourceComponent: headerLoader.sourceComponent
    property alias contentSourceComponent: contentLoader.sourceComponent
    signal categorySelected()


    Loader {
        id: headerLoader
        anchors {
            top: parent.top
        }

        width: parent.width
    }

    Rectangle {
        id: bg
        anchors {
            top: headerLoader.bottom
            left: parent.left
            right: parent.right
            bottom: contentLoader.bottom
        }

        color: {
            if (mouseArea.pressed && delegate.pressable) {
                return "#888"
            }

            if (delegate.checked && whiteBgWhenSelected) {
                return "#eee"
            }

            if (mouseArea.containsMouse) {
                return "#666"
            }

            return "#444"
        }
    }


    MouseArea {
        id: mouseArea
        anchors.fill: bg
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked:  {
            categorySelected()
            if (delegate.pressable == false) {
                return
            }
            if (delegate.checked) {
                if (uncheckable) {
                    delegate.checked = false
                }
            } else {
                delegate.checked = true
            }
        }
    }

    Loader {
        id: contentLoader

        anchors {
            top: headerLoader.bottom
            left: parent.left
            right: parent.right
        }
    }
}
