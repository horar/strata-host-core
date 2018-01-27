import QtQuick 2.7
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0
import tech.spyglass.ImplementationInterfaceBinding 1.0


ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1200
    height: 900
    title: qsTr("Spectrum Hardware Vision - Vortex Motor Demo")
    property bool hardwareStatus: null
    property bool login_detected: false

    Label {
        id: currentLabel7
        x: 118
        y: 64
        width: 51
        height: 14
    }
    Flipable {
        id: flipable
        anchors{ fill:parent }
        property bool flipped: false
        front: FrontSide{}
        back: BackSide{}
        transform: Rotation {
            id: rotation
            origin{ x: flipable.width/2;y: flipable.height/2 }
            axis{ x: 0;y: -1;z: 0 }    // set axis.y to 1 to rotate around y-axis
            angle: 0    // the default angle
        }

        states: State {
            name: "back"
            PropertyChanges { target: rotation; angle: 180 }
            when: flipable.flipped
        }

        transitions: Transition {
            NumberAnimation { target: rotation; property: "angle"; duration: 2000 }
        }
    }
}
