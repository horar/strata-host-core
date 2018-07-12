import QtQuick 2.9

Rectangle {
    id: root

    property string placement: "top"

    color: "#ddd"
    width: 1
    height: 1
    z:10

    Component.onCompleted: {
        switch (placement) {
            case "top":
                root.anchors.top = root.parent.top
                root.width = root.parent.width
                break;
            case "bottom":
                root.anchors.bottom = root.parent.bottom
                root.width = root.parent.width
                break;
            case "right":
                root.anchors.right = root.parent.right
                root.height = root.parent.height
                break;
            case "left":
                root.anchors.left = root.parent.left
                root.height = root.parent.height
                break;
        }
    }
}
