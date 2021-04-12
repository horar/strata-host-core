import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12

Button {
    id: root
    width: 30
    height: 80

    text: "Submit"

    property alias radius: background.radius

    background: Rectangle {
        id: background
        radius: 8
        gradient: Gradient {
            GradientStop { position: 0 ; color: root.hovered ? "#fff" : "#eee"}
            GradientStop { position: 1 ; color: root.hovered ? "#aaa" : "#999" }
        }
    }
}
