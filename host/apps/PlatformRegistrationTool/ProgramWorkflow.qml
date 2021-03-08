import QtQuick 2.12
import QtQuick.Controls 2.12

Item {
    id: workflow

    width: childrenRect.width
    height: childrenRect.height

    property color baseNodeColor: "#303030"
    property int arrowTailLength: Math.round(1.5*state4Label.width)

    property alias nodeSettingsHighlight: nodeSettings.highlight
    property alias nodeDownloadHighlight: nodeDownload.highlight
    property alias nodeDeviceCheckHighlight: nodeDeviceCheck.highlight
    property alias nodeProgramHighlight: nodeProgram.highlight
    property alias nodeRegistrationHighlight: nodeRegistration.highlight
    property alias nodeDoneHighlight: nodeDone.highlight

    FeedbackArrow {
        id: arrowLoop
        width: nodeDone.x - nodeDeviceCheck.x + 2*padding + wingWidth + 4
        height: 40
        x: nodeDeviceCheck.x - padding + Math.round(nodeDeviceCheck.width/2) - wingWidth - 2

        padding: 2
        color: baseNodeColor
    }

    WorkflowNode {
        id: nodeSettings
        anchors {
            horizontalCenter: label1.horizontalCenter
            top: arrowLoop.bottom
        }

        source: "qrc:/sgimages/cog.svg"
        color: baseNodeColor
        iconColor: baseNodeColor
    }

    Arrow {
        id: arrowDownload
        anchors {
            left: nodeSettings.right
            verticalCenter: nodeSettings.verticalCenter
        }

        color: baseNodeColor
        tailLength: arrowTailLength
    }

    WorkflowNode {
        id: nodeDownload
        anchors {
            verticalCenter: nodeSettings.verticalCenter
            left: arrowDownload.right
        }

        source: "qrc:/images/download-shrinked.svg"
        color: baseNodeColor
        iconColor: baseNodeColor
    }

    Arrow {
        id: arrowDeviceCheck
        anchors {
            left: nodeDownload.right
            verticalCenter: nodeDownload.verticalCenter
        }

        color: baseNodeColor
        tailLength: arrowTailLength
    }

    WorkflowNode {
        id: nodeDeviceCheck
        anchors {
            verticalCenter: nodeSettings.verticalCenter
            left: arrowDeviceCheck.right
        }

        source: "qrc:/sgimages/plug.svg"
        color: baseNodeColor
        iconColor: baseNodeColor
    }

    Arrow {
        id: arrowProgram
        anchors {
            left: nodeDeviceCheck.right
            verticalCenter: nodeSettings.verticalCenter
        }

        color: baseNodeColor
        tailLength: arrowTailLength
    }

    WorkflowNode {
        id: nodeProgram
        anchors {
            verticalCenter: nodeSettings.verticalCenter
            left: arrowProgram.right
        }

        source: "qrc:/sgimages/bolt.svg"
        color: baseNodeColor
        iconColor: baseNodeColor
    }

    Arrow {
        id: arrowRegistration
        anchors {
            left: nodeProgram.right
            verticalCenter: nodeSettings.verticalCenter
        }

        color: baseNodeColor
        tailLength: arrowTailLength
    }

    WorkflowNode {
        id: nodeRegistration
        anchors {
            verticalCenter: nodeSettings.verticalCenter
            left: arrowRegistration.right
        }

        source: "qrc:/images/letter-r.svg"
        color: baseNodeColor
        iconColor: baseNodeColor
    }

    Arrow {
        id: arrowDone
        anchors {
            left: nodeRegistration.right
            verticalCenter: nodeSettings.verticalCenter
        }

        color: baseNodeColor
        tailLength: arrowTailLength
    }

    WorkflowNode {
        id: nodeDone
        anchors {
            left: arrowDone.right
            verticalCenter: nodeSettings.verticalCenter
        }

        source: "qrc:/sgimages/check.svg"
        color: baseNodeColor
        iconColor: baseNodeColor
    }

    Arrow {
        id: arrowExit
        anchors {
            left: nodeDone.right
            verticalCenter: nodeSettings.verticalCenter
        }

        color: baseNodeColor
        tailLength: Math.round(arrowTailLength/2)
    }

    WorkflowNodeText {
        anchors {
            left: arrowExit.right
            verticalCenter: nodeSettings.verticalCenter
        }

        color: baseNodeColor
        text: "End"
        standalone: true
    }

    WorkflowNodeText {
        id: label1
        anchors {
            left: parent.left
            top: nodeSettings.bottom
        }

        text: "Settings"
        color: baseNodeColor
        highlight: nodeSettings.highlight
    }

    WorkflowNodeText {
        id: labelDownload
        anchors {
            horizontalCenter: nodeDownload.horizontalCenter
            top: nodeDownload.bottom
        }

        text: "Download\nFirmware"
        color: baseNodeColor
        highlight: nodeDownload.highlight
    }

    WorkflowNodeText {
        anchors {
            horizontalCenter: nodeDeviceCheck.horizontalCenter
            top: nodeDeviceCheck.bottom
        }

        text: "Connect New\nDevice"
        color: baseNodeColor
        highlight: nodeDeviceCheck.highlight
    }

    WorkflowNodeText {
        anchors {
            horizontalCenter: nodeProgram.horizontalCenter
            top: nodeProgram.bottom
        }

        text: "Programming"
        color: baseNodeColor
        highlight: nodeProgram.highlight
    }

    WorkflowNodeText {
        anchors {
            horizontalCenter: nodeRegistration.horizontalCenter
            top: nodeRegistration.bottom
        }

        text: "Registration"
        color: baseNodeColor
        highlight: nodeRegistration.highlight
    }

    WorkflowNodeText {
        id: state4Label
        anchors {
            horizontalCenter: nodeDone.horizontalCenter
            top: nodeDone.bottom
        }

        text: "Done"
        color: baseNodeColor
        highlight: nodeDone.highlight
    }
}
