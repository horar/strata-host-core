import QtQuick 2.0

Rectangle {
    id: container
    color: "transparent"
    width:container.width; height:container.height

    Column {
        spacing: 8
        anchors { top: container.top; topMargin: parent.width/10 }

        SGIconStatistic {
            id: negotiateValue
            width:container.width/4; height: width
            source: "leftArrow.svg"
            color: "transparent"
            SGIconLabel {
                width:container.width/4; height: width
                anchors{ left:negotiateValue.right }
            }
        }
        SGIconStatistic {
            id: velocityValue
            width: container.width/4; height: width
            source: "rightArrow.svg"
            color: "transparent"
            SGIconLabel {
                width:container.width/4; height: width
                anchors{ left:velocityValue.right }
            }
        }
        SGIconStatistic {
            id: powerTemperature
            width:container.width/4; height: width
            source: "voltageIcon.svg"
            color: "transparent"
            SGIconLabel {
                width:container.width/4; height: width
                anchors{ left:powerTemperature.right }
            }
        }
        SGIconStatistic {
            id: temperature
            width:container.width/4; height: width
            source: "temperatureIcon.svg"
            color: "transparent"
            SGIconLabel {
                width:container.width/4; height: width
                anchors{ left:temperature.right }
            }
        }
    }
}
