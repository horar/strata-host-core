import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.3

Window {
    id: mainWindow
    visible: true
    width: 1200
    height: 900
    title: qsTr("NCD5700x")

    property bool layoutColors: false

    Rectangle {
        id: root
        color: !mainWindow.layoutColors ? "white" : "tomato"
        anchors {
            fill: parent
        }

        Rectangle {
            id: titleBar
            color: !mainWindow.layoutColors ? "white" : "lightgreen"
            anchors {
                top: root.top
                left: root.left
                right: root.right
            }
            height: 50
        }

        Rectangle {
            id: leftLayout
            color: !mainWindow.layoutColors ? "white" : "lightblue"
            anchors {
                left: root.left
                verticalCenter: root.verticalCenter
                verticalCenterOffset: titleBar.height/2
            }
            width: root.width/2
            height: childrenRect.height

            Rectangle {
                id: statusLightContainer1
                color: !mainWindow.layoutColors ? "white" : "pink"
                anchors {
                    left: leftLayout.left
                }
                width: leftLayout.width / 3
                height: childrenRect.height

                SGStatusLight {
                    id: readyLight
                    anchors {
                        top: statusLightContainer1.top
                        horizontalCenter: statusLightContainer1.horizontalCenter
                    }
                    label: "<b>Ready:<b>"
                    status: "green"
                }

                SGStatusLight {
                    id: faultLight
                    anchors {
                        top: readyLight.bottom
                        topMargin: 15
                        right: readyLight.right
                    }
                    label: "<b>Fault:<b>"
                    status: "red"
                }
            }

            Rectangle {
                id: statusLightContainer2
                color: !mainWindow.layoutColors ? "white" : "pink"
                anchors {
                    left: statusLightContainer1.right
                }
                width: leftLayout.width / 3
                height: childrenRect.height

                SGStatusLight {
                    id: desatLight
                    anchors {
                        top: statusLightContainer2.top
                        horizontalCenter: statusLightContainer2.horizontalCenter
                    }
                    label: "<b>DESAT:<b>"
                }

                SGStatusLight {
                    id: uvloLight
                    anchors {
                        top: desatLight.bottom
                        topMargin: faultLight.anchors.topMargin
                        right: desatLight.right
                    }
                    label: "<b>UVLO:<b>"
                }
            }

            Rectangle {
                id: resetContainer
                color: !mainWindow.layoutColors ? "white" : "pink"
                anchors {
                    left: statusLightContainer2.right
                }
                width: leftLayout.width / 3
                height: statusLightContainer2.height

                Button {
                    id: resetButton
                    anchors { centerIn: parent }
                    text: "Reset"
                }
            }

            Rectangle {
                id: sliderContainer
                color: !mainWindow.layoutColors ? "white" : "salmon"
                anchors {
                    top: statusLightContainer1.bottom
                    left: leftLayout.left
                    right: leftLayout.right
                    leftMargin: 40
                    rightMargin: 40
                    topMargin: 40
                }
                height: childrenRect.height

                SGSlider {
                    id: primarySupplyVoltage
                    anchors {
                        left: sliderContainer.left
                        right: sliderContainer.right
                        top: sliderContainer.top
                    }
                    label: "<b>Primary Supply Voltage:</b>"
                    labelLeft: false
                }

                SGSlider {
                    id: secondarySupplyVoltage
                    anchors {
                        left: sliderContainer.left
                        right: sliderContainer.right
                        top: primarySupplyVoltage.bottom
                        topMargin: 30
                    }
                    label: "<b>Secondary Supply Voltage:</b>"
                    labelLeft: false
                }
            }

            Rectangle {
                id: dutyCycleContainer
                color: !mainWindow.layoutColors ? "white" : "lightgreen"
                anchors {
                    top: sliderContainer.bottom
                    topMargin: 40
                    left: leftLayout.left
                    right: leftLayout.right
                }
                height: childrenRect.height

                SGSubmitInfoBox {
                    id: dutyCycle
                    anchors {
                        top: dutyCycleContainer.top
                        horizontalCenter: dutyCycleContainer.horizontalCenter
                    }
                    input: "10"
                    label: "<b>Duty Cycle:</b>"
                    infoBoxWidth: 80
                    buttonText: "Apply"
                    realNumberValidation: true
                }
            }
        }

        Rectangle {
            id: rightLayout
            color: !mainWindow.layoutColors ? "white" : "mintcream"
            anchors {
                left: leftLayout.right
                right: root.right
                verticalCenter: root.verticalCenter
                verticalCenterOffset: titleBar.height/2

            }
            height: childrenRect.height

            Rectangle {
                id: graphContainer1
                anchors {
                    top: rightLayout.top
                    left: rightLayout.left
                    leftMargin: 20
                }
                width: (rightLayout.width - 60) / 2
                height: width

                SGGraph {
                    id: gateVoltageOutput
                    anchors{
                        fill: parent
                    }
                    title: "<b>Gate Voltage at Output of Gate Driver</b>"
                    xAxisTitle: "X Axis"
                    yAxisTitle: "Y Axis"
                }
            }

            Rectangle {
                id: graphContainer2
                anchors {
                    top: graphContainer1.top
                    left: graphContainer1.right
                    leftMargin: 20
                }
                width: (rightLayout.width - 60) / 2
                height: width

                SGGraph {
                    id: gateVoltageGate
                    anchors{
                        fill: parent
                    }
                    title: "<b>Gate Voltage at Gate of IGBT</b>"
                    xAxisTitle: "X Axis"
                    yAxisTitle: "Y Axis"
                }
            }

            Rectangle {
                id: graphContainer3
                anchors {
                    top: graphContainer1.bottom
                    topMargin: 20
                    left: graphContainer1.left
                }
                width: (rightLayout.width - 60) / 2
                height: width

                SGGraph {
                    id: vceIGBT
                    anchors{
                        fill: parent
                    }
                    title: "<b>VCE of IGBT</b>"
                    xAxisTitle: "X Axis"
                    yAxisTitle: "Y Axis"
                }
            }

            Rectangle {
                id: graphContainer4
                anchors {
                    top: graphContainer3.top
                    left: graphContainer3.right
                    leftMargin: 20
                }
                width: (rightLayout.width - 60) / 2
                height: width

                SGGraph {
                    id: icIGBT
                    anchors{
                        fill: parent
                    }
                    title: "<b>IC of IBGT</b>"
                    xAxisTitle: "X Axis"
                    yAxisTitle: "Y Axis"
                }
            }
        }
    }
}
