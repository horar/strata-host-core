import QtQuick 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0

Rectangle {
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: "#ccc"

    SGIcon {
        anchors.centerIn: parent
        source: "qrc:/sgimages/strata-logo.svg"
        width: 400
        height: 400
    }
}
