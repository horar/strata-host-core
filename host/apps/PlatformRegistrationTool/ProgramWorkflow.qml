import QtQuick 2.12
import QtQuick.Controls 2.12

Item {
    id: workflow

    width: childrenRect.width
    height: childrenRect.height

    property color baseNodeColor: "#303030"
    property int arrowTailLength: Math.round(1.7*labelDone.width)
    property int arrowSpacing: 8

    property bool showControllerNodes: true
    property bool showAssistedNodes: true

    property alias nodeDownloadHighlight: nodeDownload.highlight
    property alias nodeDeviceCheckHighlight: nodeControllerCheck.highlight
    property alias nodeProgramHighlight: nodeRegisterController.highlight
    property alias nodeRegistrationHighlight: nodeAssistedCheck.highlight
    property alias nodeDoneHighlight: nodeDone.highlight

    FeedbackArrow {
        id: controllerFeedbackArrow
        width: {
            var w = nodeDone.x - nodeControllerCheck.x + 2*padding + wingWidth + 4
            if (showAssistedNodes) {
                w += arrowSpacing/2
            }

            return w
        }
        height: 40
        x: nodeControllerCheck.x - padding + Math.round(nodeControllerCheck.width/2) - wingWidth - 2

        padding: 2
        color: baseNodeColor
        visible: showControllerNodes
    }

    FeedbackArrow {
        id: assistedFeedbackArrow
        width: {
            var w = nodeDone.x - nodeAssistedCheck.x + 2*padding + wingWidth + 4
            if (showControllerNodes) {
                w -= arrowSpacing/2
            }

            return w
        }
        height: {
            var h = 40
            if(showControllerNodes) {
                h -= arrowSpacing
            }

            return h
        }
        y: showControllerNodes ? arrowSpacing : 0
        x: nodeAssistedCheck.x - padding + Math.round(nodeAssistedCheck.width/2) - wingWidth - 2


        padding: 2
        color: baseNodeColor
        visible: showAssistedNodes

    }

    WorkflowNode {
        id: nodeDownload
        anchors {
            horizontalCenter: labelDownload.horizontalCenter
            top: controllerFeedbackArrow.bottom
        }

        source: "qrc:/images/download-shrinked.svg"
        color: baseNodeColor
        iconColor: baseNodeColor
    }

    Arrow {
        id: arrowControllerCheck
        anchors {
            left: nodeDownload.right
            verticalCenter: nodeDownload.verticalCenter
        }

        color: baseNodeColor
        tailLength: arrowTailLength
        visible: showControllerNodes
    }

    WorkflowNode {
        id: nodeControllerCheck
        anchors {
            verticalCenter: nodeDownload.verticalCenter
            left: arrowControllerCheck.right
        }

        source: "qrc:/sgimages/plug.svg"
        color: baseNodeColor
        iconColor: baseNodeColor
        visible: showControllerNodes
    }

    Arrow {
        id: arrowRegisterController
        anchors {
            left: nodeControllerCheck.right
            verticalCenter: nodeDownload.verticalCenter
        }

        color: baseNodeColor
        tailLength: arrowTailLength
        visible: showControllerNodes
    }

    WorkflowNode {
        id: nodeRegisterController
        anchors {
            verticalCenter: nodeDownload.verticalCenter
            left: arrowRegisterController.right
        }

        source: "qrc:/sgimages/bolt.svg"
        color: baseNodeColor
        iconColor: baseNodeColor
        visible: showControllerNodes
    }

    Arrow {
        id: arrowAssistedCheck
        anchors {
            left: showControllerNodes ? nodeRegisterController.right : nodeDownload.right
            verticalCenter: nodeDownload.verticalCenter
        }

        color: baseNodeColor
        tailLength: arrowTailLength
        visible: showAssistedNodes
    }

    WorkflowNode {
        id: nodeAssistedCheck
        anchors {
            verticalCenter: nodeDownload.verticalCenter
            left: arrowAssistedCheck.right
        }

        source: "qrc:/sgimages/plug.svg"
        color: baseNodeColor
        iconColor: baseNodeColor
        visible: showAssistedNodes
    }


    Arrow {
        id: arrowRegisterAssisted
        anchors {
            left: nodeAssistedCheck.right
            verticalCenter: nodeDownload.verticalCenter
        }

        color: baseNodeColor
        tailLength: arrowTailLength
        visible: showAssistedNodes
    }

    WorkflowNode {
        id: nodeRegisterAssisted
        anchors {
            verticalCenter: nodeDownload.verticalCenter
            left: arrowRegisterAssisted.right
        }

        source: "qrc:/sgimages/bolt.svg"
        color: baseNodeColor
        iconColor: baseNodeColor
        visible: showAssistedNodes
    }

    Arrow {
        id: arrowDone
        anchors {
            left: {
                if (showAssistedNodes) {
                    return nodeRegisterAssisted.right
                }

                if (showControllerNodes) {
                    return nodeRegisterController.right
                }

                return nodeDownload.right
            }
            verticalCenter: nodeDownload.verticalCenter
        }

        color: baseNodeColor
        tailLength: arrowTailLength
    }

    WorkflowNode {
        id: nodeDone
        anchors {
            left: arrowDone.right
            verticalCenter: nodeDownload.verticalCenter
        }

        source: "qrc:/sgimages/check.svg"
        color: baseNodeColor
        iconColor: baseNodeColor
    }

    Arrow {
        id: arrowExit
        anchors {
            left: nodeDone.right
            verticalCenter: nodeDownload.verticalCenter
        }

        color: baseNodeColor
        tailLength: Math.round(arrowTailLength/2)
    }

    WorkflowNodeText {
        anchors {
            left: arrowExit.right
            verticalCenter: nodeDownload.verticalCenter
        }

        color: baseNodeColor
        text: "End"
        standalone: true
    }

    WorkflowNodeText {
        id: labelDownload
        anchors {
            left: parent.left
            top: nodeDownload.bottom
        }

        text: "Download\nFirmware"
        color: baseNodeColor
        highlight: nodeDownload.highlight
    }

    WorkflowNodeText {
        anchors {
            horizontalCenter: nodeControllerCheck.horizontalCenter
            top: nodeControllerCheck.bottom
        }

        text: "Connect New\nController"
        color: baseNodeColor
        highlight: nodeControllerCheck.highlight
        visible: showControllerNodes
    }

    WorkflowNodeText {
        anchors {
            horizontalCenter: nodeRegisterController.horizontalCenter
            top: nodeRegisterController.bottom
        }

        text: "Register\nController"
        color: baseNodeColor
        highlight: nodeRegisterController.highlight
        visible: showControllerNodes
    }

    WorkflowNodeText {
        anchors {
            horizontalCenter: nodeAssistedCheck.horizontalCenter
            top: nodeAssistedCheck.bottom
        }

        text: {
            if (showControllerNodes) {
                return "Connect New\nAssisted Device"
            }
            return"Connect New\n Device"
        }
        color: baseNodeColor
        highlight: nodeAssistedCheck.highlight
        visible: showAssistedNodes
    }

    WorkflowNodeText {
        anchors {
            horizontalCenter: nodeRegisterAssisted.horizontalCenter
            top: nodeRegisterAssisted.bottom
        }

        text: {
            if (showControllerNodes) {
                return "Register\nAssisted Device"
            }
            return "Register\nDevice"
        }
        color: baseNodeColor
        highlight: nodeAssistedCheck.highlight
        visible: showAssistedNodes
    }

    WorkflowNodeText {
        id: labelDone
        anchors {
            horizontalCenter: nodeDone.horizontalCenter
            top: nodeDone.bottom
        }

        text: "Done"
        color: baseNodeColor
        highlight: nodeDone.highlight
    }
}
