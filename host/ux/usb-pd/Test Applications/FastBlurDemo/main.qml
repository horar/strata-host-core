import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0


ApplicationWindow {
    id: applicationWindow
    visible: true
    width: 700
    height: 700
    title: qsTr("Hello World")

    Rectangle {
        id: container
        anchors.fill: parent

        Image {
            id: image

            anchors.fill: parent
            source: "melania.jpg"
        }

        Rectangle {
            width: 50
            height: 50
            x: 50
            y: 50
            color: "red"
        }
    }


    NumberAnimation {
        id: blurAnimation
        target: blur
        property: "radius"
        duration: 1000
        from: 0
        to: 50
        easing.type: Easing.InSine

        onStopped:{
            showPopup();
        }
    }

    NumberAnimation {
        id: focusAnimation
        target: blur
        property: "radius"
        duration: 1000
        from: 50
        to: 0
        easing.type: Easing.InOutQuad
    }


    ShaderEffectSource {
        id: effectSource

        sourceItem: container
        anchors.fill: container
        sourceRect: Qt.rect(x,y, width, height)
    }

    FastBlur{
        id: blur
        visible: false
        anchors.fill: effectSource

        source: effectSource
        radius: 100
    }

    Button {
        id: button
        x: 300
        y: 660
        text: qsTr("Pop me!")
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        onClicked: {
            blur.visible = true //blur the background
            blurAnimation.start()
            }
        }

    function showPopup(){
        thePopup.open();
    }


    MyPopup {
        id: thePopup
        x: 100
        y: 100
        width: 500
        height: 500
        modal: true
        focus: true
        dim: false      //don't dim the background
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        onAboutToHide: {
            focusAnimation.start();
        }
    }
}
