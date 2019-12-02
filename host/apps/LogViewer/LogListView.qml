import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.fonts 1.0 as StrataFonts

Item {
    id: modelWrapper

    property alias model: logListView.model
    property alias currentIndex: logListView.currentIndex
    property int cellWidthSpacer: 6
    property int cellHeightSpacer: 6
    property int checkBoxSpacer: 60
    property int handleSpacer: 5
    property int searchResultCount: model.count
    property bool timestampColumnVisible: true
    property bool pidColumnVisible: true
    property bool tidColumnVisible: true
    property bool levelColumnVisible: true
    property bool messageColumnVisible: true
    property bool startAnimation: false
    property bool sidePanelShown: true
    property int sidePanelWidth: 150
    property bool messageWrapEnabled: true
    property bool searchTagShown: false
    property var highlightColor

    signal currentItemChanged(int index)

    function positionViewAtIndex(index, param) {
        logListView.positionViewAtIndex(index, param)
    }

    //fontMetrics.boundingRect(text) does not re-evaluate itself upon changing the font size
    TextMetrics {
        id: textMetricsTs
        font: timestampHeaderText.font
        text: "9999-99-99 99:99.99.999 XXX+99:9999"
    }

    TextMetrics {
        id: textMetricsPid
        font: timestampHeaderText.font
        text: "9999999999"
    }

    TextMetrics {
        id: textMetricsTid
        font: timestampHeaderText.font
        text: "9999999999"
    }

    TextMetrics {
        id: textMetricsLevel
        font: timestampHeaderText.font
        text: "[ 99 ]"
    }

    TextMetrics {
        id: textMetricsSidePanel
        font: timestampHeaderText.font
        text: " Timestamp "
    }

    Item {
        id: header
        height: headerContent.height + 8
        anchors {
            top: parent.top
            left: parent.left
            leftMargin: sidePanelShown ? 4 : 0
            right: logListView.right
        }

        Rectangle {
            id: headerBg
            anchors.fill: parent
            color: "black"
            opacity: 0.2
        }

        Row {
            id: headerContent
            height: timestampHeaderText.contentHeight + cellHeightSpacer
            anchors {
                verticalCenter: parent.verticalCenter
            }
            leftPadding: handleSpacer

            Item {
                id: headerSpacer
                width: 1
            }

            Item {
                id: tsHeader
                height: timestampHeaderText.contentHeight + cellHeightSpacer
                width: textMetricsTs.boundingRect.width + cellWidthSpacer
                visible: timestampColumnVisible

                SGWidgets.SGText {
                    id: timestampHeaderText
                    anchors {
                        left: tsHeader.left
                        verticalCenter: parent.verticalCenter
                    }
                    font.family: StrataFonts.Fonts.inconsolata
                    text: qsTr("Timestamp")
                }
            }

            Item {
                id: pidHeader
                height: pidHeaderText.contentHeight + cellHeightSpacer
                width: textMetricsPid.boundingRect.width + cellWidthSpacer
                visible: pidColumnVisible

                SGWidgets.SGText {
                    id: pidHeaderText
                    anchors {
                        left: pidHeader.left
                        verticalCenter: parent.verticalCenter
                    }
                    font.family: StrataFonts.Fonts.inconsolata
                    text: qsTr("PID")
                }
            }

            Item {
                id: tidHeader
                height: tidHeaderText.contentHeight + cellHeightSpacer
                width: textMetricsTid.boundingRect.width + cellWidthSpacer
                visible: tidColumnVisible

                SGWidgets.SGText {
                    id: tidHeaderText
                    anchors {
                        left: tidHeader.left
                        verticalCenter: parent.verticalCenter
                    }
                    font.family: StrataFonts.Fonts.inconsolata
                    text: qsTr("TID")
                }
            }

            Item {
                id: levelHeader
                height: levelHeaderText.contentHeight + cellHeightSpacer
                width: textMetricsLevel.boundingRect.width + cellWidthSpacer
                visible: levelColumnVisible

                SGWidgets.SGText {
                    id: levelHeaderText
                    anchors {
                        left: levelHeader.left
                        verticalCenter: parent.verticalCenter
                    }
                    font.family: StrataFonts.Fonts.inconsolata
                    text: qsTr("Level")
                }
            }
        }

        Item {
            id: msgHeader
            height: levelHeaderText.contentHeight + cellHeightSpacer
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: header.right
            anchors.left: headerContent.right
            visible: messageColumnVisible

            SGWidgets.SGText {
                id: messageHeaderText
                anchors {
                    left: msgHeader.left
                    verticalCenter: parent.verticalCenter
                }
                font.family: StrataFonts.Fonts.inconsolata
                text: qsTr("Message")
            }
        }

        SGWidgets.SGTag {
            id: searchTag
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                rightMargin: 5
            }
            visible: searchTagShown
            text: searchResultCount == 1 ? "Search Result: " + searchResultCount : "Search Results: " + searchResultCount
        }
    }

    ListView {
        id: logListView
        anchors {
            top: header.bottom
            left: header.left
            right: parent.right
            bottom: parent.bottom
        }
        contentHeight: parent.height
        flickableDirection: Flickable.VerticalFlick
        boundsMovement: Flickable.StopAtBounds
        boundsBehavior: Flickable.DragAndOvershootBounds
        highlightMoveDuration: 0
        highlightMoveVelocity: -1

        ScrollBar.vertical: ScrollBar {
            minimumSize: 0.1
            policy: ScrollBar.AlwaysOn
        }
        clip: true

        delegate: FocusScope {
            id: delegate
            width: parent.width
            height: row.height


            ListView.onCurrentItemChanged : {
                if (ListView.isCurrentItem && startAnimation) {
                    cellAnimation.start()
                } else {
                    cellAnimation.complete()
                }
            }

            ParallelAnimation {
                id: cellAnimation
                loops: 1
                running: false
                SequentialAnimation {
                    ColorAnimation {
                        target: cell
                        property: "color"
                        from: "white"
                        to: highlightColor
                        duration: 400
                    }
                    ColorAnimation {
                        target: cell
                        property: "color"
                        from: highlightColor
                        to: "white"
                        duration: 400
                    }
                }
                SequentialAnimation {
                    ColorAnimation {
                        targets: [ts,pid,tid,level,msg]
                        properties: "color"
                        from: "black"
                        to: "white"
                        duration: 400
                    }
                    ColorAnimation {
                        targets: [ts,pid,tid,level,msg]
                        properties: "color"
                        from: "white"
                        to: "black"
                        duration: 400
                    }
                }
            }

            Rectangle {
                id: cell
                anchors.fill: parent
                color: {
                    if (delegate.ListView.isCurrentItem) {
                        if (modelWrapper.activeFocus) {
                            return highlightColor
                        } else {
                            return "darkgray"
                        }
                    } else
                        return "white"
                }

                MouseArea {
                    anchors.fill: parent
                    onPressed:  {
                        modelWrapper.forceActiveFocus()
                        logListView.currentIndex = index
                        currentItemChanged(index)
                    }
                }
            }

            Row {
                id: row
                leftPadding: handleSpacer

                SGWidgets.SGText {
                    id: ts
                    width: tsHeader.width
                    color: delegate.ListView.isCurrentItem ? "white" : "black"
                    font.family: StrataFonts.Fonts.inconsolata
                    text: visible ? model.timestamp : ""
                    visible: timestampColumnVisible
                }

                SGWidgets.SGText {
                    id: pid
                    width: pidHeader.width
                    color: delegate.ListView.isCurrentItem ? "white" : "black"
                    font.family: StrataFonts.Fonts.inconsolata
                    text: visible ? model.pid : ""
                    visible: pidColumnVisible
                }

                SGWidgets.SGText {
                    id: tid
                    width: tidHeader.width
                    color: delegate.ListView.isCurrentItem ? "white" : "black"
                    font.family: StrataFonts.Fonts.inconsolata
                    text: visible ? model.tid : ""
                    visible: tidColumnVisible
                }

                SGWidgets.SGText {
                    id: level
                    width: levelHeader.width
                    color: delegate.ListView.isCurrentItem ? "white" : "black"
                    font.family: StrataFonts.Fonts.inconsolata
                    text: visible ? model.level : ""
                    visible: levelColumnVisible
                }

                SGWidgets.SGText {
                    id: msg
                    width: msgHeader.width
                    color: delegate.ListView.isCurrentItem ? "white" : "black"
                    font.family: StrataFonts.Fonts.inconsolata
                    text: visible ? model.message : ""
                    visible: messageColumnVisible
                    wrapMode: messageWrapEnabled ? Text.WrapAtWordBoundaryOrAnywhere : Text.NoWrap
                    elide: messageWrapEnabled ? Text.ElideNone : Text.ElideRight
                }
            }
        }
    }

    Keys.onPressed: {
        if (event.key === Qt.Key_Up && currentIndex > 0){
            currentIndex = currentIndex - 1
            currentItemChanged(currentIndex)
        }
        else if (event.key === Qt.Key_Down && currentIndex < (searchResultCount - 1)) {
            currentIndex = currentIndex + 1
            currentItemChanged(currentIndex)
        }
    }
}
