import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12

Button {
    id: root

    property alias radius: background.radius

    width: 30
    height: 80
    text: "Submit"

    background: Rectangle {
        id: background
        radius: 8
        gradient: Gradient {
            GradientStop { position: 0 ; color: root.hovered ? "#fff" : "#eee"}
            GradientStop { position: 1 ; color: root.hovered ? "#aaa" : "#999" }
        }
    }
}
