import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0

SGMainWindow {
    id:  window
    title: qsTr("Platform Interface Generator")
    minimumHeight: 400
    minimumWidth: 600

    visible: true

    Rectangle {
        id: container
        anchors.fill: parent
        anchors.margins: 20

        TabBar {
            id: navTabs
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            TabButton {
                id: importerButton
                KeyNavigation.right: this
                KeyNavigation.left: this
                text: qsTr("Import JSON file")
                onClicked: {
                    stackContainer.currentIndex = 0
                }
            }

            TabButton {
                id: creatorButton
                KeyNavigation.right: this
                KeyNavigation.left: this
                text: qsTr("Create from scratch")
                onClicked: {
                    stackContainer.currentIndex = 1
                }
            }
        }

        Rectangle {
            id: divider
            anchors {
                top: navTabs.bottom
                topMargin: 10
                left: parent.left
                right: parent.right
            }

            height: 1
            width: parent.width
            color: "black"
        }

        StackLayout {
            id: stackContainer
            anchors {
                top: divider.bottom
                topMargin: 20
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }

            JsonImporter {
                id: importer
                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: Math.min(750, parent.width)
            }

            PlatformInterfaceCreator {
                id: creator

                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }
}
