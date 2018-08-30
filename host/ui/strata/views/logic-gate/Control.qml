import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
//import tech.spyglass. 1.0
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/views/motor-vortex/sgwidgets"

Rectangle {
    id: controlNavigation
    anchors {
        fill: parent
    }

    PlatformInterface {
        id: platformInterface
    }

    TabBar {
        id: navTabs
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        TabButton {
            id: basicButton
            text: qsTr("NL7SZ58")
            onClicked: {
                controlContainer.currentIndex = 0
            }
        }

        TabButton {
            id: advancedButton
            text: qsTr("NL7SZ97 ")
            onClicked: {

                controlContainer.currentIndex = 1
            }
        }


    }

    ScrollView {
        anchors {
            top: navTabs.bottom
            bottom: parent.bottom
            right: parent.right
            left: parent.left
        }

        onWidthChanged: {
            if (width < 1200) {
                ScrollBar.horizontal.policy = ScrollBar.AlwaysOn
            } else {
                ScrollBar.horizontal.policy = ScrollBar.AlwaysOff
            }
        }

        onHeightChanged: {
            if (height < 725) {
                ScrollBar.vertical.policy = ScrollBar.AlwaysOn
            } else {
                ScrollBar.vertical.policy = ScrollBar.AlwaysOff
            }
        }

        Flickable {
            id: controlContainer

            property int currentIndex: 0

            onCurrentIndexChanged: {
                switch (currentIndex){
                case 0:
                    partOne.visible = true
                    partTwo.visible = false

                    break;
                case 1:
                    partOne.visible = false
                    partTwo.visible = true
                    break;

                }
            }

            boundsBehavior: Flickable.StopAtBounds
            contentWidth: 1200
            contentHeight: 725
            anchors {
                fill: parent
            }
            clip: true



          PartOne {
              id: partOne
              visible: true
              Component.onCompleted: {
                  console.log("hghg")
              }

          }

          PartTwo {
              id: partTwo
              visible: false
          }
        }
    }
}

