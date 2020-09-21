import QtQuick 2.12
import QtQuick.Controls 2.12

RoundButton {
    id: root

    function startAnimation()
    {
        qmlErrorButtonAnimation.start()
    }

    function stopAnimation()
    {
        qmlErrorButtonAnimation.stop()
    }
    
    anchors {
        bottom: parent.bottom
        left: parent.left
        bottomMargin: 20
        leftMargin: 20
    }
    
    font {
        bold: true
    }
    checkable: true
    
    NumberAnimation on opacity {
        id: qmlErrorButtonAnimation
        
        from: 0.6
        to: 1.0
        duration: 1500
        
        easing.type: Easing.OutQuart
        loops: Animation.Infinite
    }
}
