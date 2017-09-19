import QtQuick 2.0
import QtQuick.Controls 2.0

Rectangle {
     id: container
     color: "transparent"
     width:container.width; height: container.height
     property alias source: iconImage.source

    Image {
        id:iconImage
        width: container.width; height: container.height
    }
}


