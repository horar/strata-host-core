import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import tech.spyglass.ImplementationInterfaceBinding 1.0
import "framework"
import "views"

Rectangle {
    id: controlPage
    objectName: "controlLayout"

    property bool hardwareStatusChange: true
    property bool boardScreen: true

    //actions to take when the control layout view becomes visible from being pushed on the stack
    onOpacityChanged: {

        if (opacity == 1) {
            rotateInfoIcon.start()
        }

        if (opacity == 1 && frontToolBar.visible == false) {
            frontToolBar.visible = true
            frontToolBar.opacity = 0
            fadeInFrontToolBar.start()
        }
    }

    // border.color: "red"; border.width: 1 // debug layout

    // ----------------
    // LOGO
    Rectangle {
        id: headerLogo
        anchors { top: parent.top }
        width: parent.width; height: 40
        color: "#235A92"

        Image {
            anchors { top: parent.top; right: parent.right }
            height: 40
            fillMode: Image.PreserveAspectFit
            source: "./images/icons/onLogoGreenWithText.png"
        }
    }

    // ----------------
    // Speed Dial
    //

    // Values are being Signalled from ImplementationInterfaceBinding.cpp
    Connections {
        target: implementationInterfaceBinding

        // motor speed
        onMotorSpeedChanged: {
            console.log("MOTOR SPEED UPDATE: ", motor_speed);
        }
    }


    Rectangle {
        id: speedDial

        anchors { centerIn: parent }
        width: 300; height: 300

        //color: "#545454"

        Dial {
            id: dial
            anchors.centerIn: parent

            //value: slider.x * 100 / (container.width - 32)  // debug. tied directly to the slider
            value: implementationInterfaceBinding.motor_speed * 100 / (container.width - 32)

        }

        Rectangle {
            id: container
            property int oldWidth: 0

            anchors { bottom: parent.bottom; left: parent.left
                right: parent.right; leftMargin: 20; rightMargin: 20
                bottomMargin: 10
            }

            height: 16

            radius: 8
            opacity: 0.7
            antialiasing: true
            gradient: Gradient {
                GradientStop { position: 0.0; color: "gray" }
                GradientStop { position: 1.0; color: "white" }
            }

            onWidthChanged: {
                if (oldWidth === 0) {
                    oldWidth = width;
                    return
                }

                var desiredPercent = slider.x * 100 / (oldWidth - 32)
                slider.x = desiredPercent * (width - 32) / 100
                oldWidth = width
            }

            Rectangle {
                id: slider
                x: 1; y: 1; width: 30; height: 14
                radius: 6
                antialiasing: true
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#424242" }
                    GradientStop { position: 1.0; color: "black" }
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -16 // Increase mouse area outside slider
                    drag.target: parent; drag.axis: Drag.XAxis
                    drag.minimumX: 2; drag.maximumX: container.width - 32
                }
            }
        }
    }

    ButtonGroup {
        buttons: buttonColumn.children
    }

    GroupBox {
        title: "<b><font color='red'>Operation Mode</b></font>"
        anchors { top: speedDial.bottom; topMargin: 40; horizontalCenter: parent.horizontalCenter}

        Row {
            id: buttonColumn
            anchors {fill: parent}

            RadioButton {
                checked: true
                text: "Manual Control"

                onPressed: {
                    console.log("MANUAL CONTROL")

                }
            }

            RadioButton {
                text: "Automatic Test Pattern"

                onPressed: {
                    console.log("AUTOMATIC")

                }
            }
        }
    }

    // INFO ICON
    Image {
        id: infoIcon
        anchors{ bottom: parent.bottom;
            bottomMargin: 10
            right: parent.right
            rightMargin: 10}
        height: 50; width:50
        source:"./images/icons/infoIcon.svg"
        layer.enabled: true
        layer.effect: DropShadow {
            anchors.fill: infoIcon
            horizontalOffset: 2
            verticalOffset: 2
            radius: 12.0
            samples: 24
            color: "#60000000"
            source: infoIcon
        }

        transform: Rotation {
            id: zRot
            origin.x: infoIcon.width/2; origin.y: infoIcon.height/2;
            axis { x: 0; y: 1; z: 0 }
        }

        NumberAnimation {
            id:rotateInfoIcon
            running: false
            loops: 1
            target: zRot;
            property: "angle";
            from: 0; to: 360;
            duration: 1000;
        }

        ScaleAnimator {
            id: increaseOnMouseEnter
            target: infoIcon;
            from: 1;
            to: 1.2;
            duration: 200
            running: false
        }

        ScaleAnimator {
            id: decreaseOnMouseExit
            target: infoIcon;
            from: 1.2;
            to: 1;
            duration: 200
            running: false
        }

        MouseArea {
            id: imageMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: flipable.flipped = !flipable.flipped
            onEntered:{
                increaseOnMouseEnter.start()
            }
            onExited:{
                decreaseOnMouseExit.start()
            }
        }
    }
}
