import QtQuick 2.12

Item {
    id: root

    implicitHeight: 40
    implicitWidth: implicitHeight

    property int iconStatus: SGStatusLight.Off

    enum IconStatus {
        Green,
        Red,
        Yellow,
        Orange,
        Off
    }

    Image {
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        mipmap: true

        source: {
            switch(iconStatus) {
            case SGStatusLight.Green: return "qrc:/images/greenStatusLight.svg"
            case SGStatusLight.Red: return "qrc:/images/redStatusLight.svg"
            case SGStatusLight.Yellow: return "qrc:/images/yellowStatusLight.svg"
            case SGStatusLight.Orange: return "qrc:/images/orangeStatusLight.svg"
            default: return "qrc:/images/offStatusLight.svg"
            }
        }
    }
}
