import QtQuick 2.0


Rectangle {
     id: container
     width:container.width; height:container.height

     Rectangle {
         id: divider       
         x:0;y:0
         width: container.width/10; height:container.height/1.4
         color: "black"
         opacity: 1.0
     }
}
