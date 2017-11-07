import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

ApplicationWindow {
    id: applicationWindow
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")

    PathAnimation {
        path: Path {
            //no startX, startY
            PathCurve { x: 100; y: 100}
            PathCurve {}    //last element is empty with no end point specified
        }
    }

    Rectangle {
        id: redRectangle
        x: 105
        y: 181
        width: 100
        height: 100
        color: "#eb0606"

    }

    Rectangle {
        id: greenRectangle
        x: 253
        y: 181
        width: 100
        height: 100
        color: "#06cb48"

    }

    Rectangle {
        id: blueRectangle
        x: 404
        y: 181
        width: 100
        height: 100
        color: "#0713e1"

    }

    Button {
        id: button
        x: 253
        y: 326
        text: qsTr("Fade!")
        spacing: -4

        SequentialAnimation {
            id: sequentialFade
            running: false
            OpacityAnimator {
                    target: redRectangle;
                    id: fadeOutRedTriangle;
                    from: 0;
                    to: 1;
                    duration: 1000;
                    //running: true;
                }
            OpacityAnimator {
                    target: greenRectangle;
                    id: fadeOutGreenRectangle;
                    from: 0;
                    to: 1;
                    duration: 1000
                }
            OpacityAnimator {
                    target: blueRectangle;
                    id: fadeOutBlueRectangle;
                    from: 0;
                    to: 1;
                    duration: 1000
                }
            }

        onClicked:{
            redRectangle.opacity = 0
            greenRectangle.opacity = 0
            blueRectangle.opacity = 0
            sequentialFade.start()

        }
    }


}
