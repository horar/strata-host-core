import QtQuick 2.0

Rectangle {
    id: loadingBarContainer
    x: platformStack.width / 2 - width / 2
    y: platformStack.height / 2 - height / 2

    width: platformStack.width * .5
    height: 15

    color: "grey"
    visible: true

    enum Status {
        Null,
        Loading,
        FullyLoaded
    }

    property double percentReady: 0.0
    property int status: LoadingBar.Status.Null
    property alias color: loadingBar.color

    onPercentReadyChanged: {
        if (percentReady <= 0.0) {
            status = LoadingBar.Status.Null
        } else if (percentReady === 1.0) {
            status = LoadingBar.Status.FullyLoaded
        } else {
            status = LoadingBar.Status.Loading
        }
    }

    Rectangle {
        id: loadingBar
        z: 100
        height: parent.height
        width: loadingBarContainer.width * percentReady
        color: "#57d445"
    }
}
