import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import tech.spyglass.userinterfacebinding 1.0

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1200
    height: 900
    title: "ON Semi Platform X Demonstration Tool"

    Rectangle {
        id: startupDialog

        anchors { top: parent.top }
        width: mainWindow.width; height: mainWindow.height
        //border.color: "green"; border.width: 2 // debug
        opacity: 1
        z:2

        // Logo
        Rectangle {
            id: headerLogo
            anchors { top: parent.top }
            width: parent.width; height: 40
            color: "#235A92"
        }
        Image {
            anchors { top: parent.top; right: parent.right }
            height: 40
            fillMode: Image.PreserveAspectFit
            source: "onsemi_logo.png"
        }

        Rectangle {
            id: statusMessageBox
            anchors { top: headerLogo.bottom; topMargin: 10; horizontalCenter: startupDialog.horizontalCenter}
            width: statusMessage.width + 10; height: statusMessage.height + 10
            border.color: "black"; border.width: 2; radius: 4;
            color: "#ef7a7a" // red'ish

            Label {
                id: statusMessage
                anchors { centerIn: parent}

                text: "Detecting Platform Hardware"
                font { pixelSize: 22
                       bold: true }
                color: "black"
            }
        }

        // ----------------------------------
        // platform section
        Image {
            id: platformBoardImage
            anchors { top: statusMessageBox.bottom; topMargin: 100; left: startupDialog.left; leftMargin: 100}
            width: 200; height: 164
            source: "motor_board_platform.png"
            opacity: 0

            // Runs immediately instead of on change of opacity value. ??? OpacityAnimator on opacity { from: 0; to: 1; duration: 2000 }
            OpacityAnimator {
                id: platformBoardImageAnimator
                target: platformBoardImage
                from: 0; to: 1; duration: 2500; running: false
            }
        }

        Rectangle {
            id: platformTypeMessageBox
            anchors { top: platformBoardImage.bottom; topMargin: 10; horizontalCenter: platformBoardImage.horizontalCenter}
            width: platformTypeMessage.width + 10; height: platformTypeMessage.height + 10
            border.color: "black"; border.width: 2; radius: 4;
            color: "#7aef9d"
            opacity: 0

            OpacityAnimator {
                id: platformTypeMessageBoxAnimator
                target: platformTypeMessageBox
                from: 0; to: 1; duration: 2500; running: false
            }

            Label {
                id: platformTypeMessage
                anchors { centerIn: parent}

                text: "Automotive USB-PD Platform"
                font.pixelSize: 22
                font.bold: true
                color: "black"
            }
        }

        // cloud section
        Image {
            id: cloudImage
            anchors { top: statusMessageBox.bottom; topMargin: 100; right: startupDialog.right; rightMargin: 100}
            width: 200; height: 164
            source: "download_from_cloud.png"
            opacity: 0
            OpacityAnimator {
                id: cloudImageAnimator
                target: cloudImage
                from: 0; to: 1; duration: 2500; running: false
            }

            ScaleAnimator {
                id: cloudAnimator
                target: cloudImage
                from: 1; to: 0.95
                easing.type: Easing.OutBounce
                duration: 1500
                loops: Animation.Infinite
            }
        }

        Rectangle {
            id: cloudMessageBox
            anchors { top: platformBoardImage.bottom; topMargin: 10; horizontalCenter: cloudImage.horizontalCenter}
            width: cloudMessage.width + 10; height: cloudMessage.height + 10
            border.color: "black"; border.width: 2; radius: 4;
            color: "#ef7a7a"
            opacity: 0
            OpacityAnimator {
                id: cloudMessageBoxAnimator
                target: cloudMessageBox
                from: 0; to: 1; duration: 2500; running: false
            }

            Label {
                id: cloudMessage
                anchors { centerIn: parent}

                text: "Downloading configuration"
                font.pixelSize: 22
                font.bold: true
                color: "black"
            }
        }

        Button {
            id: confirmButton
            anchors { top: platformTypeMessageBox.bottom; topMargin: 10; horizontalCenter: startupDialog.horizontalCenter}
            text: "Confirm"
            visible: false
            onClicked: {
                dialogAnimationClose.start()
            }
        }

        BusyIndicator {
            //anchors { top: statusMessageBox.bottom; topMargin: 10; horizontalCenter: startupDialog.horizontalCenter}
            anchors { centerIn: startupDialog}
            running: detectionTimer.running || downloadTimer.running
        }

    }

    // enable to allow time to screen capture startup detection
    // TODO if you comment this out ... set detectionTimer.running = true
    Timer {
        id: startDelayTimer
        interval: 500; running: true; repeat: false
        onTriggered: {
            detectionTimer.start()
        }
    }

    Timer {
        id: detectionTimer
        interval: 500; repeat: false; running: false

        onTriggered: {
            statusMessageBox.color = "#7aef9d"; // green
            statusMessage.text = "ON Hardware Platform Detected";
            platformBoardImageAnimator.start()
            platformTypeMessageBoxAnimator.start();

            cloudImageAnimator.start();
            cloudMessageBoxAnimator.start()
            downloadTimer.start()
            cloudAnimator.start()
        }
    }

    Timer {
        id: downloadTimer
        interval: 500; running: false; repeat: false
        onTriggered: {
            cloudMessageBox.color = "#7aef9d" // green
            cloudMessage.text = "COMPLETE"
            confirmButton.visible = true
            cloudAnimator.stop()
        }
    }

    PropertyAnimation {
        id: dialogAnimationClose

        target: startupDialog; properties: "height"
        from: startupDialog.height; to: 0; duration: 1500

        onStopped: {
            startupDialog.visible = false
        }
    }

    SwipeView {
        id: swipeView
        anchors.fill: parent
        currentIndex: tabBar.currentIndex

        z:1

        PageControl { id: pageControlID
            width: parent.parent.width; height: parent.parent.height
        }
        PageBOM { id: pageBOMID }
        PageSchematic { id: pageSchematic }
        PageAssembly { id: pageAssembly }
        PagePCB { id: pagePCB }
        PageReport { id: pageReport }
        PageRelated { id: pageRelated }
        PageMagazine { id: pageMagazine }
        PageBusinessIntelligence { id: pageBusinessIntelligence }
    }

    footer: TabBar {
        id: tabBar
        currentIndex: swipeView.currentIndex
        TabButton { text: "Control" }
        TabButton { text: "BOM" }
        TabButton { text: "Schematic" }
        TabButton { text: "Assembly" }
        TabButton { text: "PCB Layout" }
        TabButton { text: "Test Report" }
      }
}
