import QtQuick 2.12
import QtQuick.Controls 1.5
import QtQuick.Layouts 1.12

SplitView {
    id: splitView

    handleDelegate: Rectangle {
        implicitWidth: 1
        implicitHeight: 1

        color: styleData.pressed ? "#0066ff" : "#9d9d9d"
    }
}
