import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
//import tech.spyglass. 1.0
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/views/logic-gate/sgwidgets"

Item {
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
            horizontalCenter: parent.horizontalCenter
        }

        TabButton {
            id: basicButton
            text: qsTr("NL7SZ97")
            onClicked: {
                controlContainer.currentIndex = 0
                console.log("in view one")
                partOne.visible = true
                partTwo.visible = false
                partOne.resetToIndex0();
            }
        }

        TabButton {
            id: advancedButton
            text: qsTr("NL7SZ58")
            onClicked: {
                platformInterface.off_97_led.update()
                controlContainer.currentIndex = 1
                console.log("in view two")
                partOne.visible = false
                partTwo.visible = true
                partTwo.resetToIndex0()
                platformInterface.nand.update()
            }
        }
    }
    Item {
        id: controlContainer
        property int currentIndex: 0
        anchors {
            top: navTabs.bottom
            bottom: controlNavigation.bottom
            right: controlNavigation.right
            left: controlNavigation.left
        }

       PartOne  {
            id: partOne
            visible: true
        }

        PartTwo {
            id: partTwo
            visible: false
        }
    }

//    ScrollView {
//        anchors {
//            top: navTabs.bottom
//            bottom: parent.bottom
//            right: parent.right
//            left: parent.left
//            fill: parent
//        }

//        onWidthChanged: {
//            if (width < 1200) {
//                ScrollBar.horizontal.policy = ScrollBar.AlwaysOn
//            } else {
//                ScrollBar.horizontal.policy = ScrollBar.AlwaysOff
//            }
//        }

//        onHeightChanged: {
//            if (height < 725) {
//                ScrollBar.vertical.policy = ScrollBar.AlwaysOn
//            } else {
//                ScrollBar.vertical.policy = ScrollBar.AlwaysOff
//            }
//        }

//        Flickable {
//            id: controlContainer
//            property int currentIndex: 0
//            boundsBehavior: Flickable.StopAtBounds
//            contentWidth: 1200
//            contentHeight: 725

//            clip: true

//            PartOne {
//                id: partOne
//                visible: true

//            }

//            PartTwo {
//                id: partTwo
//                visible: false
//            }
//        }
//    }
}

