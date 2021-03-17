import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12

Item {
    objectName: "ControlViewRoot"

    property int columnCount: 20
    property int rowCount: 20
    property real columnSize: width / columnCount
    property real rowSize: height / rowCount
}
