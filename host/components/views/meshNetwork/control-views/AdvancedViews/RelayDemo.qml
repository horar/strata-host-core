import QtQuick 2.12
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import tech.strata.sgwidgets 1.0


Rectangle {
    id: root

    Image{
            anchors.fill: parent
            source: "qrc:/views/meshNetwork/images/relayDemo.png"
            height:parent.height
            anchors.centerIn: parent
            fillMode: Image.PreserveAspectFit
            mipmap:true
        }
}
