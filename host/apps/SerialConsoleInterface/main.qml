import QtQuick 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import Qt.labs.platform 1.1 as QtLabsPlatform

SGWidgets.SGWindow {
    id: window

    visible: true
    height: 600
    width: 800
    minimumHeight: 600
    minimumWidth: 800

    title: qsTr("Serial Console Interface")

    QtLabsPlatform.MenuBar {
        QtLabsPlatform.Menu {
            title: "File"
            QtLabsPlatform.MenuItem {
                text: qsTr("&Exit")
                onTriggered:  {
                    Qt.quit()
                }
            }
        }

        QtLabsPlatform.Menu {
            title: "Help"
            QtLabsPlatform.MenuItem {
                text: qsTr("&About")
                onTriggered:  {
                    showAboutWindow()
                }
            }
        }
    }

    Rectangle {
        id: bg
        anchors.fill: parent
        color:"#eeeeee"
    }

    SciMain {
        anchors.fill: parent
    }

    Loader {
        id: aboutWindowLoader

        Connections {
            target: aboutWindowLoader.item
            onClosing: {
                close.accepted = false
                aboutWindowLoader.source = ""
            }
        }
    }

    function showAboutWindow() {
        if (aboutWindowLoader.status === Loader.Null) {
            aboutWindowLoader.source = "qrc:/SciAboutWindow.qml"
        } else if (aboutWindowLoader.status === Loader.Ready) {
            aboutWindowLoader.item.raise()
            aboutWindowLoader.item.requestActivate()
        }
    }
}
