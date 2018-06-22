import QtQuick 2.0
import QtQuick.Controls 2.3

Button {
    id: root
    text: qsTr("Button")
    checkable: true
    enabled: masterEnabled

    // Figures out which button this instance is
    Component.onCompleted: {
        if (root.parent.children.length === 1) {
            // single button style (hopefully this is never used)
            flatSide.width = 0;
            flatSide.height = 0;
        } else if (root.parent.children[root.parent.children.length-1] === root){
            // last button style
            flatSide.anchors.left = buttonStyle.left;
        } else if (root.parent.children[0] === root){
            // first button style
            flatSide.anchors.right = buttonStyle.right;
        } else {
            //middle buttons style
            flatSide.width = 0;
            flatSide.height = 0;
            buttonStyle.radius = 0;
        }
    }

    property real radius: masterRadius
    property color activeColorTop: masterActiveColorTop
    property color activeColorBottom: masterActiveColorBottom
    property color inactiveColorTop: masterInactiveColorTop
    property color inactiveColorBottom: masterInactiveColorBottom
    property color textColor: masterTextColor
    property color textActiveColor: masterActiveTextColor

    background: Rectangle{
        id: buttonStyle
        gradient: Gradient {
            GradientStop { position: 0.0; color: root.checked ? activeColorTop : inactiveColorTop }
            GradientStop { position: 1.0; color: root.checked ? activeColorBottom : inactiveColorBottom }
        }
        radius: root.radius
        implicitHeight: masterHeight
        implicitWidth: 70
        opacity: root.enabled ? 1.0 : 0.3
        layer.enabled: true

        Rectangle{
            id: flatSide
            height: parent.height
            width: parent.width/2

            gradient: Gradient {
                GradientStop { position: 0.0; color: root.checked ? activeColorTop : inactiveColorTop }
                GradientStop { position: 1.0; color: root.checked ? activeColorBottom : inactiveColorBottom }
            }
        }
    }

    contentItem: Text {
        text: root.text
        opacity: root.enabled ? 1.0 : 0.3
        color: root.checked ? root.textActiveColor : root.textColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
}
