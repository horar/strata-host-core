import QtQuick 2.12
import QtQuick.Controls 2.12

import "./common" as Common
import "./common/Colors.js" as Colors

Item {
    id: boardStatus

    property bool showIsConnected: true
    property bool showIsRegistered: true
    property bool showBootloaderId: true
    property bool showWarning: false
    property bool isConnected: false
    property bool isRegistered: false
    property string bootloaderId
    property string firmwareId
    property string verboseName
    property string boardRevision
    property string opn
    property int year
    property variant applicationTagList: []
    property variant productTagList: []
    property string description
    property string boardImageSrc
    property int horizontalSpacing: 4
    property int verticalSpacing: 6

    function clear() {
        isRegistered = false;
        bootloaderId = ""
        firmwareId = ""
        verboseName = ""
        boardRevision = ""
        opn = ""
        year = ""
        applicationTagList = []
        productTagList = []
        description = ""
        boardImageSrc = ""
    }

    Common.SgText {
        id: dummyText
        visible: false

        text: "this is super long long name"
        font.bold: true
        horizontalAlignment: Text.AlignRight
        elide: Text.ElideRight
    }

    Column {
        anchors {
            top: parent.top
            topMargin: 10
            horizontalCenter: parent.horizontalCenter
        }

        visible: showWarning
        spacing: verticalSpacing

        Common.SgText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "No Board Detected"
            fontSizeMultiplier: 2.0
        }

        Common.SgText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Connect board to see detailed information"
            font.italic: true
        }
    }

    Item {
        id: imageWrapper
        anchors {
            top: parent.top
            right: parent.right
        }

        width: 300
        height: 200

        Image {
            id: boardImage
            anchors.fill: parent

            horizontalAlignment: Image.AlignRight
            verticalAlignment: Image.AlignTop
            fillMode: Image.PreserveAspectFit
            source: boardImageSrc
        }
    }

    Column {
        id: infoColumn
        anchors {
            top: parent.top
        }

        spacing: verticalSpacing
        visible: !showWarning

        Row {
            spacing: horizontalSpacing
            visible: showIsConnected

            Common.SgText {
                anchors.verticalCenter: parent.verticalCenter
                width: dummyText.paintedWidth

                text: "Connected:"
                font.bold: dummyText.font.bold
                horizontalAlignment: dummyText.horizontalAlignment
                elide: dummyText.elide
            }

            Common.SgText {
                text: isConnected  ? "yes" : "no"
                color: isConnected ? normalColor : "red"
            }
        }

        Row {
            spacing: horizontalSpacing
            visible: showIsRegistered

            Common.SgText {
                anchors.verticalCenter: parent.verticalCenter
                width: dummyText.paintedWidth

                text: "Registered:"
                font.bold: dummyText.font.bold
                horizontalAlignment: dummyText.horizontalAlignment
                elide: dummyText.elide
            }

            Common.SgText {
                text: isRegistered ? "yes" : "no"
                color: isRegistered ? normalColor : "red"
            }
        }

        Row {
            spacing: horizontalSpacing
            visible: showBootloaderId

            Common.SgText {
                anchors.verticalCenter: parent.verticalCenter
                width: dummyText.paintedWidth

                text: "Bootloader:"
                font.bold: dummyText.font.bold
                horizontalAlignment: dummyText.horizontalAlignment
                elide: dummyText.elide
            }

            Common.SgText {
                text: bootloaderId
            }
        }

        Row {
            spacing: horizontalSpacing

            Common.SgText {
                anchors.verticalCenter: parent.verticalCenter
                width: dummyText.paintedWidth

                text: "Ordering Part Number:"
                font.bold: dummyText.font.bold
                horizontalAlignment: dummyText.horizontalAlignment
                elide: dummyText.elide
            }

            Common.SgText {
                text: opn
            }
        }

        Row {
            spacing: horizontalSpacing

            Common.SgText {
                anchors.verticalCenter: parent.verticalCenter
                width: dummyText.paintedWidth

                text: "Verbose Name:"
                font.bold: dummyText.font.bold
                horizontalAlignment: dummyText.horizontalAlignment
                elide: dummyText.elide
            }

            Common.SgText {
                text: verboseName
            }
        }

        Row {
            spacing: horizontalSpacing

            Common.SgText {
                anchors.verticalCenter: parent.verticalCenter
                width: dummyText.paintedWidth

                text: "Firmware:"
                font.bold: dummyText.font.bold
                horizontalAlignment: dummyText.horizontalAlignment
                elide: dummyText.elide
            }

            Common.SgText {
                text: firmwareId
            }
        }

        Row {
            spacing: horizontalSpacing

            Common.SgText {
                anchors.verticalCenter: parent.verticalCenter
                width: dummyText.paintedWidth

                text: "Board Revision:"
                font.bold: dummyText.font.bold
                horizontalAlignment: dummyText.horizontalAlignment
                elide: dummyText.elide
            }

            Common.SgText {
                text: boardRevision
            }
        }

        Row {
            spacing: horizontalSpacing

            Common.SgText {
                anchors.verticalCenter: parent.verticalCenter
                width: dummyText.paintedWidth

                text: "Year:"
                font.bold: dummyText.font.bold
                horizontalAlignment: dummyText.horizontalAlignment
                elide: dummyText.elide
            }

            Common.SgText {
                text: year
            }
        }

    }
    Column {
        id: tagInfoColumn
        anchors {
            top: imageWrapper.bottom
            topMargin: verticalSpacing
            left: parent.left
            right: parent.right
        }

        spacing: verticalSpacing
        visible: !showWarning

        Row {
            width: parent.width
            spacing: horizontalSpacing

            Common.SgText {
                id: appTagLabel
                anchors.verticalCenter: parent.verticalCenter
                width: dummyText.paintedWidth

                text: "Application Tags:"
                font.bold: dummyText.font.bold
                horizontalAlignment: dummyText.horizontalAlignment
                elide: dummyText.elide
            }

            Common.SgTagFlow {
                width: parent.width - x
                tagColor: Colors.APPLICATION_TAG
                model: applicationTagList
            }
        }

        Row {
            width: parent.width
            spacing: horizontalSpacing

            Common.SgText {
                anchors.verticalCenter: parent.verticalCenter
                width: dummyText.paintedWidth

                text: "Product Tags:"
                font.bold: dummyText.font.bold
                horizontalAlignment: dummyText.horizontalAlignment
                elide: dummyText.elide
            }

            Common.SgTagFlow {
                width: parent.width - x
                tagColor: Colors.PRODUCT_TAG
                model: productTagList
            }
        }

        Row {
            width: parent.width
            spacing: horizontalSpacing

            Common.SgText {
                anchors.verticalCenter: parent.verticalCenter
                width: dummyText.paintedWidth

                text: "Description:"
                font.bold: dummyText.font.bold
                horizontalAlignment: dummyText.horizontalAlignment
                elide: dummyText.elide
            }

            Common.SgText {
                width: parent.width - x
                text: description
                wrapMode: Text.Wrap
            }
        }
    }
}
